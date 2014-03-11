require_relative('api_actions.rb')

class PickpointApi::Session
  include(::PickpointApi::Exceptions)
  include(::PickpointApi::Constants)
  include(::PickpointApi::ApiActions)

  attr_reader :state
  attr_reader :test

  def initialize(hash = {})
    @state = :new
    @test = hash[:test] == true
  end

  private
  def raise_if_error(response, error_field = 'Error', error = ApiError)
    message = error_message(response, error_field)
    return response unless message

    yield if block_given?
    raise error, message
  end

  def error_message(response, error_field = 'Error')
    if response.is_a?(String) && response.start_with?('Error')
      response
    elsif !response[error_field].nil? && !response[error_field].empty?
      response[error_field]
    end
  end

  def sendings_request(action, data)
    ensure_session_state
    data = attach_session_id(data, 'Sendings')
    json_request(action, data)
  end

  def parameterless_request(action)
    ensure_session_state
    response = execute_action(action)
    JSON.parse(response)
  end

  def ensure_session_state(state = :started)
    raise InvalidSessionState if @state != state
  end

  def json_request(action, data)
    response = execute_action(action, data)
    JSON.parse(response)
  end

  def request_by_invoice_ids(invoice_ids, action)
    ensure_session_state
    data = if invoice_ids.kind_of?(Array)
      invoice_ids
    else
      [invoice_ids]
    end

    data = attach_session_id(data, 'Invoices')
    raise_if_error execute_action(action, data)
  end

  def return_request(action, ikn, document_number, date_from, date_to = DateTime.now)
    ensure_session_state
    data = {
      'SessionId' => @session_id,
      'IKN' => ikn,
      'DocumentNumber' => document_number,
      'DateFrom' => date_from.strftime(DATE_FORMAT),
      'DateEnd' => date_to.strftime(DATE_FORMAT)
    }
    raise_if_error json_request(action, data)
  end

  def request_by_invoice_id(action, invoice_id = nil, sender_invoice_number = nil)
    ensure_session_state

    data = { 'SessionId' => @session_id }
    data['InvoiceNumber'] = invoice_id unless invoice_id.nil?
    data['SenderInvoiceNumber'] = sender_invoice_number unless sender_invoice_number.nil?

    json_request(action, data)
  end

  def api_path
    @test ? API_TEST_PATH : API_PROD_PATH
  end

  def create_request(action)
    action_config = ACTIONS[action]

    raise UnknownApiAction, action if action_config.nil?

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

    raise ApiError, response.body if response.code != '200'

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
