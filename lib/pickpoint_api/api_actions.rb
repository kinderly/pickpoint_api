require('net/http')
require('json')
require('date')

module PickpointApi::ApiActions
  include(::PickpointApi::Exceptions)
  include(::PickpointApi::Constants)

  # Начало сессии
  def login(login, password)
    ensure_session_state(:new)
    data = {'Login' => login, 'Password' => password}
    response = execute_action(:login, data)
    response = JSON.parse(response)
    check_for_error(response, 'ErrorMessage', LoginError) do
      @state = :error
    end

    @session_id = response['SessionId']
    @state = :started
    nil
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

  # Регистрация одноместных отправлений
  def create_sending(data)
    sendings_request(:create_sending, data)
  end

  # Регистрация многоместных отправлений
  def create_shipment(data)
    sendings_request(:create_shipment, data)
  end

  # Создание отправления клиентского возврата
  def make_return(options)
    ensure_session_state

    if !options[:invoice_id].nil? && !options[:sender_invoice_number].nil?
      raise ApiError 'Only :invoice_id or :sender_invoice_number parameter should be specified'
    end

    data = {
      'SessionId' => @session_id
    }

    if !options[:invoice_id].nil?
      data['InvoiceNumber'] = options[:invoice_id]
    elsif !options[:sender_invoice_number].nil?
      data['GCInvoiceNumber'] = options[:sender_invoice_number]
    else
      raise ApiError 'Either :invoice_id or :sender_invoice_number parameter should be specified'
    end

    response = execute_action(:get_delivery_cost, data)
    res = JSON.parse(response)

    errors = res.select do |x|
      !x['Error'].nil? && !x['Error'].empty?
    end.map do |x|
      x['Error']
    end

    if !errors.empty
      raise ApiError errors.join(';')
    end

    res
  end

  # Получение списка возвратных отправлений
  def get_return_invoices_list(date_from, date_to = DateTime.now)
    ensure_session_state
    data = {
      'SessionId' => @session_id,
      'DateFrom' => date_from.strftime(DATE_FORMAT),
      'DateTo' => date_to.strftime(DATE_FORMAT)
    }
    response = execute_action(:get_return_invoice_list, data)
    res = JSON.parse(response)
    check_for_error(res, 'Error')
  end

  # Мониторинг отправления
  def track_sending(invoice_id = nil, sender_invoice_number = nil)
    request_by_invoice_id(:track_sending, invoice_id, sender_invoice_number)
  end

  # Получение информации по отправлению
  def sending_info(invoice_id = nil, sender_invoice_number = nil)
    request_by_invoice_id(:sending_info, invoice_id, sender_invoice_number)
  end

  # Получение стоимости доставки
  def get_delivery_cost(options)
    ensure_session_state

    if !options[:invoice_ids].nil? && !options[:sender_invoice_numbers].nil?
      raise ApiError 'Only :invoice_ids or :sender_invoice_numbers parameter should be specified'
    end

    data = if !options[:invoice_ids].nil?
      options[:invoice_ids].map do |invoice_id|
        {'InvoiceNumber' => invoice_id}
      end
    elsif !options[:sender_invoice_numbers].nil?
      options[:invoice_ids].map do |invoice_id|
        {'SenderInvoiceNumber' => invoice_id}
      end
    else
      raise ApiError 'Either :invoice_ids or :sender_invoice_numbers parameter should be specified'
    end

    data = attach_session_id('Sendings', data)
    response = execute_action(:get_delivery_cost, data)
    JSON.parse(response)
  end

  # Вызов курьера
  def courier(data)
    ensure_session_state
    data = data.clone
    data['SessionId'] = @session_id
    response = execute_action(:courier, data)
    res = JSON.parse(response)
    check_for_error(res, 'ErrorMessage', CourierError)
  end

  # Отмена вызова курьера
  def courier_cancel(courier_order_number)
    ensure_session_state
    data = attach_session_id('OrderNumber', courier_order_number)
    response = execute_action(:courier_cancel, data)
    res = JSON.parse(response)
    res['Canceled']
  end

  # Формирование реестра по списку отправлений в PDF
  def make_reestr(invoice_id)
    request_by_invoice_ids(invoice_id, :make_reestr)
  end

  # Формирование реестра (по списку отправлений)
  def make_reestr_number(invoice_ids)
    ensure_session_state
    response = request_by_invoice_ids(invoice_ids, :make_reestr_number)
    res = JSON.parse(response)
    check_for_error(res, 'ErrorMessage')
    res['Numbers']
  end

  # Получение созданного реестра в PDF
  def get_reestr(invoice_id = nil, reestr_number = nil)
    ensure_session_state
    data = {
      'SessionId' => @session_id
    }
    data['InvoiceNumber'] = invoice_id if !invoice_id.nil?
    data['ReestrNumber'] = reestr_number if !reestr_number.nil?
    response = execute_action(:get_reestr, data)

    if response.start_with?('Error')
      raise ApiError, response
    else
      return response
    end
  end

  # Формирование этикеток в PDF
  def make_label(invoice_id)
    request_by_invoice_ids(invoice_id, :make_label)
  end

  # Формирование этикеток в PDF для принтера Zebra
  def make_zlabel(invoice_id)
    request_by_invoice_ids(invoice_id, :make_zlabel)
  end

  # Получение списка городов
  def city_list
    parameterless_request(:city_list)
  end

  # Получение списка терминалов
  def postamat_list
    parameterless_request(:postamat_list)
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

  # Получение акта возврата денег
  def get_money_return_order(ikn, document_number, date_from, date_to = DateTime.now)
    return_request(:get_money_return_order, ikn, document_number, date_from, date_to)
  end

  # Получение акта возврата товара
  def get_product_return_order(ikn, document_number, date_from, date_to = DateTime.now)
    return_request(:get_product_return_order, ikn, document_number, date_from, date_to)
  end

  # Получение информации по вложимому
  def enclose_info(barcode)
    ensure_session_state
    data = attach_session_id('Barcode', barcode)
    response = execute_action(:enclose_info, data)
    res = JSON.parse(response)
    check_for_error(res, 'Error')
  end

  # Получение истории по списку отправлений
  def track_sendings(invoice_id)
    request_by_invoice_ids(invoice_id, :track_sendings)
  end

  # Получение справочника статусов отправления
  def get_states
    parameterless_request(:get_states)
  end

  # Получение списка отправлений, прошедших этап (статус)
  def get_invoices_change_state(state, date_from, date_to = DateTime.now)
    ensure_session_state
    data = {
      'SessionId' => @session_id,
      'DateFrom' => date_from.strftime(DATE_FORMAT),
      'DateTo' => date_to.strftime(DATE_FORMAT),
      'State' => state
    }
    response = execute_action(:get_invoices_change_state, data)
    JSON.parse(response)
  end

end
