require 'net/http'


module HttpMocking

  def self.set_next_response(response_body, code = 200, msg='OK')
    Net::HTTP.any_instance.stub(:request) do |req|
      response = Net::HTTPResponse.new(1.0, code, msg)
      response.stub(:body => response_body)
      response
    end
  end

end
