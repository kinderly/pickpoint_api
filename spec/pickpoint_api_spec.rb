require('logger')
require_relative 'spec_helper.rb'

include DummyData

describe 'PickpointApi' do
  it 'should run session' do
    HttpMocking.enqueue_response(LOGIN_SUCCESSFUL)
    HttpMocking.enqueue_response(LOGOUT_SUCCESSFUL)

    PickpointApi.session('login', 'password', test:true) do |s|
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

  it 'should assign logger' do
    PickpointApi.logger = nil
    PickpointApi.logger = Logger.new($stderr)
    expect(PickpointApi.logger).not_to be_nil
  end

  it 'should handle session error' do
    PickpointApi.logger.level = Logger::UNKNOWN

    HttpMocking.enqueue_response(LOGIN_SUCCESSFUL)
    HttpMocking.enqueue_response(PDF_ERROR)
    HttpMocking.enqueue_response(LOGOUT_SUCCESSFUL)

    expect do
      PickpointApi.session('login', 'password', test:true) do |s|
        s.make_label('111111')
      end
    end.to raise_error PickpointApi::Exceptions::ApiError
  end

end
