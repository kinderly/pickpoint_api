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

  def check_for_error(response, error_field, error = ApiError)
    if !response[error_field].nil? && !response[error_field].empty?
      yield if block_given?
      raise error, response[error_field]
    else
      response
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
    if @state != state
      raise InvalidSessionState
    end
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

    data = attach_session_id(data,'Invoices')
    response = execute_action(action, data)

    if response.start_with?('Error')
      raise ApiError, response
    else
      return response
    end
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
    json_request(action, data)
    check_for_error(res, 'Error')
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

    json_request(action, data)
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

    if response.code != '200'
      raise ApiError, response.body
    end

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
