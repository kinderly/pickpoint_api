require('net/http')
require('json')

class PickpointApi::Session
  attr_reader :state
  attr_reader :test

  def initialize(hash = {})
    @state = :new
    @test = hash[:test] == true
  end

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

  def close
    if @session_id.present? && @state == :started
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

  def create_sending(data)
    if @state == :started
      data = attach_session_id(data, 'Sendings')
      response = execute_action(:create_sending, data)
      response = JSON.parse(response)
    end
  end

  def track_sending(invoice_id)
    if @state != :started
      return nil
    end

    data = invoice_id
    data = attach_session_id(data, 'InvoiceNumber')
    response = execute_action(:track_sending, data)

    if response.blank?
      return nil
    end
    response = JSON.parse(response)
  end

  def postamats
    if @state == :started
      response = execute_action(:postamat_list)
      response = JSON.parse(response)
    end
  end

  def make_label(invoice_id)
    if @state != :started
      return nil
    end

    if invoice_id.kind_of?(Array)
      data = invoice_id
    elsif
      data = [invoice_id]
    end

    data = attach_session_id(data,'Invoices')
    response = execute_action(:make_label, data)

    if response.start_with?("Error")
      raise ::PickpointApi::Exceptions::ApiError, response
      return nil
    else
      return response
    end
  end

  def make_reestr(invoice_id)
    if @state != :started
      return nil
    end

    if invoice_id.kind_of?(Array)
      data = invoice_id
    elsif
      data = [invoice_id]
    end

    data = attach_session_id(data,'Invoices')
    response = execute_action(:make_reestr, data)

    if response.start_with?("Error")
      raise ::PickpointApi::Exceptions::ApiError, response
      return nil
    else
      return response
    end
  end

  private

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
    req = create_request action

    if req.nil?
      return nil
    end

    req.body = data.to_json

    response = send_request(req)

    response.body
  end

  def send_request(req)
    ::Net::HTTP.start(::PickpointApi::API_HOST, ::PickpointApi::API_PORT) do |http|
      http.request(req)
    end
  end

end
