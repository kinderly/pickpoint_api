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
    response = json_request(:login, data)

    raise_if_error(response, 'ErrorMessage', LoginError) do
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
    response = json_request(:logout, data)

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
    raise_if_options_incorrect(options, :invoice_id, :sender_invoice_number)
    data = { 'SessionId' => @session_id }

    if !options[:invoice_id].nil?
      data['InvoiceNumber'] = options[:invoice_id]
    elsif !options[:sender_invoice_number].nil?
      data['GCInvoiceNumber'] = options[:sender_invoice_number]
    end

    response = json_request(:make_return, data)
    raise_if_error(response)
    response
  end

  # Получение списка возвратных отправлений
  def get_return_invoices_list(date_from, date_to = DateTime.now)
    ensure_session_state
    data = {
      'SessionId' => @session_id,
      'DateFrom' => date_from.strftime(DATE_FORMAT),
      'DateTo' => date_to.strftime(DATE_FORMAT)
    }
    res = json_request(:get_return_invoice_list, data)
    raise_if_error res
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
    raise_if_options_incorrect(options, :invoice_ids, :sender_invoice_numbers)

    data = if !options[:invoice_ids].nil?
      options[:invoice_ids].map do |invoice_id|
        {'InvoiceNumber' => invoice_id}
      end
    elsif !options[:sender_invoice_numbers].nil?
      options[:invoice_ids].map do |invoice_id|
        {'SenderInvoiceNumber' => invoice_id}
      end
    end

    data = attach_session_id('Sendings', data)
    json_request(:get_delivery_cost, data)
  end

  # Вызов курьера
  def courier(data)
    ensure_session_state
    data = data.clone
    data['SessionId'] = @session_id
    res = json_request(:courier, data)
    raise_if_error(res, 'ErrorMessage', CourierError)
  end

  # Отмена вызова курьера
  def courier_cancel(courier_order_number)
    ensure_session_state
    data = attach_session_id('OrderNumber', courier_order_number)
    res = json_request(:courier_cancel, data)
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
    raise_if_error(res, 'ErrorMessage')
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
    raise_if_error(response)
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
    data['ToPT'] = pt unless pt.nil?
    json_request(:get_zone, data)
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
    res = json_request(:enclose_info, data)
    raise_if_error(res)
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
    json_request(:get_invoices_change_state, data)
  end

end
