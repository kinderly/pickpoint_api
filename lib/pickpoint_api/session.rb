require('net/http')
require('json')
require('date')

class PickpointApi::Session
  attr_reader :state
  attr_reader :test

  def initialize(hash = {})
    @state = :new
    @test = hash[:test] == true
  end

  # Начало сессии
  def login(login, password)
    if @state!= :new
      return nil
    end

    data = {'Login' => login, 'Password' => password}
    response = execute_action(:login, data)
    response = JSON.parse(response)

    if response['ErrorMessage'].nil? && !response['SessionId'].nil?
      @session_id = response['SessionId']
      @state = :started
    else
      @state = :error
      raise ::PickpointApi::Exceptions::ApiError, response['ErrorMessage']
    end
  end

  # Завершение сессии
  def logout
    if !@session_id.nil? && @state == :started
      data = {'SessionId' => @session_id}
      response = execute_action :logout, data
      response = JSON.parse(response)
      if response['Success']
        @state = :closed
        @session_id = nil
        return true
      else
        return false
      end
    else
      return false
    end
  end

  # Регистрация одноместного отправления
  def create_sending(data)
    if @state == :started
      data = attach_session_id(data, 'Sendings')
      response = execute_action(:create_sending, data)
      response = JSON.parse(response)
    end
  end

  # Мониторинг отправления
  def track_sending(invoice_id)
    request_by_invoice_id(invoice_id, :track_sending)
  end

  # Получение информации по отправлению
  def sending_info(invoice_id)
    request_by_invoice_id(invoice_id, :sending_info)
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

  # Получение справочника статусов отправления
  def get_states
    if @state != :started
      return nil
    end

    response = execute_action(:get_states)
    response = JSON.parse(response)
  end

  # Получение списка городов
  def city_list
    if @state != :started
      return nil
    end

    response = execute_action(:city_list)
    response = JSON.parse(response)
  end

  # Получение списка терминалов
  def postamat_list
    if @state == :started
      response = execute_action(:postamat_list)
      response = JSON.parse(response)
    end
  end

  # Получение списка отправлений, прошедших этап (статус)
  def get_invoices_change_state(state, date_from = nil, date_to = DateTime.now)
    data = {
      'SessionId' => @session_id,
      'DateTo' => date_to.strftime('%d.%m.%y'),
      'State' => state
    }

    if !date_from.nil?
      data['DateFrom'] = date_from.strftime('%d.%m.%y')
    end

    response = execute_action(:get_invoices_change_state, data)

    JSON.parse(response)
  end

  private

  def request_by_invoice_ids(invoice_ids, action)
    if @state != :started
      return nil
    end

    data = if invoice_ids.kind_of?(Array)
      invoice_ids
    else
      [invoice_ids]
    end

    data = attach_session_id(data,'Invoices')
    response = execute_action(action, data)

    if response.start_with?("Error")
      raise ::PickpointApi::Exceptions::ApiError, response
      return nil
    else
      return response
    end
  end

  def request_by_invoice_id(invoice_id, action)
    if @state != :started
      return nil
    end

    data = attach_session_id(invoice_id, 'InvoiceNumber')
    response = execute_action(action, data)

    if(response.nil? || response.empty?)
      []
    else
      JSON.parse(response)
    end
  end

  def api_path
    if @test
      ::PickpointApi::Constants::API_TEST_PATH
    else
      ::PickpointApi::Constants::API_PROD_PATH
    end
  end

  def create_request(action)
    action_config = ::PickpointApi::Constants::ACTIONS[action]
    if action_config.nil?
      return nil
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
    ::PickpointApi.logger.debug("Request: action: #{action}; data: #{data.inspect}")
    req = create_request(action)

    if req.nil?
      return nil
    end

    req.body = data.to_json
    response = send_request(req)
    log_response(response)
    response.body
  end

  def send_request(req)
    ::Net::HTTP.start(::PickpointApi::Constants::API_HOST, ::PickpointApi::Constants::API_PORT) do |http|
      http.request(req)
    end
  end

  def log_response(response)
    if !response.body.nil?
      if response.body.start_with?('%PDF')
        ::PickpointApi.logger.debug("Response: #{response.code}; data: PDF")
      end
        ::PickpointApi.logger.debug("Response: #{response.code}; data: #{response.body}")
      else
    end
  end

end
