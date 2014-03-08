require('net/http')
require('json')
require('date')

class PickpointApi::Session
  include(::PickpointApi::Exceptions)
  include(::PickpointApi::Constants)

  attr_reader :state
  attr_reader :test

  def initialize(hash = {})
    @state = :new
    @test = hash[:test] == true
  end

  # Начало сессии
  def login(login, password)
    ensure_session_state(:new)
    data = {'Login' => login, 'Password' => password}
    response = execute_action(:login, data)
    response = JSON.parse(response)

    if response['ErrorMessage'].nil? && !response['SessionId'].nil?
      @session_id = response['SessionId']
      @state = :started
    else
      @state = :error
      raise LoginError, response['ErrorMessage']
    end
  end

  # Завершение сессии
  def logout
    ensure_session_state

    data = {'SessionId' => @session_id}
    response = execute_action :logout, data
    response = JSON.parse(response)

    if response['Success'] == true
      @state = :closed
      @session_id = nil
    else
      @state = :error
      raise LogoutError
    end

  end

  # Регистрация одноместного отправления
  def create_sending(data)
    ensure_session_state
    data = attach_session_id(data, 'Sendings')
    response = execute_action(:create_sending, data)
    response = JSON.parse(response)
  end

  # Мониторинг отправления
  def track_sending(invoice_id = nil, sender_invoice_number = nil)
    request_by_invoice_id(:track_sending, invoice_id, sender_invoice_number)
  end

  # Получение информации по отправлению
  def sending_info(invoice_id = nil, sender_invoice_number = nil)
    request_by_invoice_id(:sending_info, invoice_id, sender_invoice_number)
  end

  # Формирование этикеток в PDF
  def make_label(invoice_id)
    request_by_invoice_ids(invoice_id, :make_label)
  end

  # Формирование этикеток в PDF для принтера Zebra
  def make_zlabel(invoice_id)
    request_by_invoice_ids(invoice_id, :make_zlabel)
  end

  # Формирование реестра по списку отправлений в PDF
  def make_reestr(invoice_id)
    request_by_invoice_ids(invoice_id, :make_reestr)
  end

  # Получение истории по списку отправлений
  def track_sendings(invoice_id)
    request_by_invoice_ids(invoice_id, :track_sendings)
  end

  # Получение справочника статусов отправления
  def get_states
    parameterless_request(:get_states)
  end

  # Получение списка городов
  def city_list
    parameterless_request(:city_list)
  end

  # Получение списка терминалов
  def postamat_list
    parameterless_request(:postamat_list)
  end

  # Получение списка отправлений, прошедших этап (статус)
  def get_invoices_change_state(state, date_from, date_to = DateTime.now)
    ensure_session_state
    data = {
      'SessionId' => @session_id,
      'DateFrom' => date_from.strftime('%d.%m.%y'),
      'DateTo' => date_to.strftime('%d.%m.%y'),
      'State' => state
    }
    response = execute_action(:get_invoices_change_state, data)
    JSON.parse(response)
  end

  # Получение списка возвратных отправлений
  def get_return_invoices_list(date_from, date_to = DateTime.now)
    ensure_session_state
    data = {
      'SessionId' => @session_id,
      'DateFrom' => date_from.strftime('%d.%m.%y'),
      'DateTo' => date_to.strftime('%d.%m.%y')
    }
    response = execute_action(:get_return_invoice_list, data)
    res = JSON.parse(response)

    if !res['Error'].nil? && !res['Error'].empty?
      raise ApiError res['Error']
    end

    res
  end

  # Получение информации по зонам
  def get_zone(city, pt = nil)
    ensure_session_state
    data = {
      'SessionId' => @session_id,
      'FromCity' => city
    }

    if !pt.nil?
      data['ToPT'] = pt
    end

    response = execute_action(:get_zone, data)
    JSON.parse(response)
  end

  # Вызов курьера
  def courier(data)
    ensure_session_state
    data = data.clone
    data['SessionId'] = @session_id
    response = execute_action(:courier, data)
    res = JSON.parse(response)

    if !res['ErrorMessage'].nil? && !res['ErrorMessage'].empty?
      raise CourierError, res['ErrorMessage']
    end

    res
  end

  # Отмена вызова курьера
  def courier_cancel(courier_order_number)
    ensure_session_state
    data = attach_session_id("OrderNumber", courier_order_number)
    response = execute_action(:courier_cancel, data)
    res = JSON.parse(response)
    res['Canceled']
  end

  # Получение информации по вложимому
  def enclose_info(barcode)
    ensure_session_state
    data = attach_session_id('Barcode', barcode)
    response = execute_action(:enclose_info, data)
    res = JSON.parse(response)

    if !res['Error'].nil? && !res['Error'].empty?
      raise ApiError res['Error']
    end

    res
  end

  private

  def parameterless_request(action)
    ensure_session_state
    response = execute_action(action)
    JSON.parse(response)
  end

  def ensure_session_state(state = :started)
    if @state != state
      raise InvalidSessionState
    end
  end

  def request_by_invoice_ids(invoice_ids, action)
    ensure_session_state
    data = if invoice_ids.kind_of?(Array)
      invoice_ids
    else
      [invoice_ids]
    end

    data = attach_session_id(data,'Invoices')
    response = execute_action(action, data)

    if response.start_with?('Error')
      raise ApiError, response
    else
      return response
    end
  end

  def request_by_invoice_id(action, invoice_id = nil, sender_invoice_number = nil)
    ensure_session_state
    data = {
      'SessionId' => @session_id
    }

    if !invoice_id.nil?
      data['InvoiceNumber'] = invoice_id
    end

    if !sender_invoice_number.nil?
      data['SenderInvoiceNumber'] = sender_invoice_number
    end

    response = execute_action(action, data)

    if(response.nil? || response.empty?)
      []
    else
      JSON.parse(response)
    end
  end

  def api_path
    if @test
      API_TEST_PATH
    else
      API_PROD_PATH
    end
  end

  def create_request(action)
    action_config = ACTIONS[action]

    if action_config.nil?
      raise UnknownApiAction, action
    end

    action_path = "#{api_path}#{action_config[:path]}"

    if action_config[:method] == :post
      req = ::Net::HTTP::Post.new action_path
    elsif action_config[:method] == :get
      req = ::Net::HTTP::Get.new action_path
    end

    req.content_type = 'application/json'
    req
  end

  def attach_session_id(data, key)
    {
      'SessionId' => @session_id,
      key => data
    }
  end

  def execute_action(action, data = {})
    logger.debug("Request: action: #{action}; data: #{data.inspect}")
    req = create_request(action)
    req.body = data.to_json
    response = send_request(req)
    log_response(response)
    response.body
  end

  def send_request(req)
    ::Net::HTTP.start(API_HOST, API_PORT) do |http|
      http.request(req)
    end
  end

  def log_response(response)
    if !response.body.nil?
      if response.body.start_with?('%PDF')
        logger.debug("Response: #{response.code}; data: PDF")
      else
        logger.debug("Response: #{response.code}; data: #{response.body[0,200]}#{response.body.size > 200 ? '...' : ''}")
      end
    end
  end

  def logger
    ::PickpointApi.logger
  end

end
