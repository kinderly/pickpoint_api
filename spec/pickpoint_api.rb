require_relative '../lib/pickpoint_api.rb'
require_relative './support/dummy_data.rb'
require_relative './support/http_mocking.rb'

include DummyData

describe 'PickpointApi' do
  it 'should run session' do
    HttpMocking.set_next_response(LOGIN_SUCCESSFULL)

    PickpointApi.session('login', 'password', test:true) do |s|
      HttpMocking.set_next_response(LOGOUT_SUCCESSFULL)
    end
  end
end
