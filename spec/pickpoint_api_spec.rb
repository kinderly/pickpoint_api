require('logger')
require_relative 'spec_helper.rb'

include DummyData

describe 'PickpointApi' do
  it 'should run session' do
    HttpMocking.set_next_response(LOGIN_SUCCESSFULL)

    PickpointApi.session('login', 'password', test:true) do |s|
      HttpMocking.set_next_response(LOGOUT_SUCCESSFULL)
    end
  end

  it 'should write logs' do

    PickpointApi.logger.level = Logger::UNKNOWN
    PickpointApi.logger.info('INFO')
    PickpointApi.logger.error('ERROR')
    PickpointApi.logger.warn('WARNING')
    PickpointApi.logger.fatal('FATAL')
    PickpointApi.logger.debug('DEBUG')
  end

end
