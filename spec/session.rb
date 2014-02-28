# coding: utf-8

require_relative '../lib/pickpoint_api.rb'
require_relative './support/dummy_data.rb'

include DummyData

describe ::PickpointApi::Session do
  before(:each) do
    @session = ::PickpointApi::Session.new(test: true)

    @session.stub(:send_request) do |req|
        response = double()
        response.stub(:body => LOGIN_SUCCESSFULL)
        response
    end
  end

  it 'can instatiate' do
    expect(@session).not_to be_nil
    expect(@session.test).to eq true
    expect(@session.state).to eq :new
  end

  describe '.login' do
    it 'should log-in' do
      @session.login('login', 'password')
      expect(@session.state).to eq :started
    end

    it 'should handle incorrect login' do
      @session.stub(:send_request) do |req|
        response = double()
        response.stub(:body => LOGIN_FAILED)
        response
      end

      expect { @session.login('login', 'password') }.to raise_error ::PickpointApi::Exceptions::ApiError
      expect(@session.state).to eq(:error)
    end
  end

  describe '.logout' do
    it 'should log out' do
      @session.login('login', 'password')

      @session.stub(:send_request) do |req|
        response = double()
        response.stub(:body => LOGOUT_SUCCESSFULL)
        response
      end

      expect(@session.logout).to eq(true)
      expect(@session.state).to eq(:closed)
    end
  end

  describe '.create_sending' do
    it 'should handle succesfull request' do
      @session.login('login', 'password')

      @session.stub(:send_request) do |req|
        response = double()
        response.stub(:body => CREATE_SENDING_SUCCESSFULL)
        response
      end

      res = @session.create_sending(SAMPLE_SENDING_REQUEST)
      expect(res['CreatedSendings']).not_to be_empty
      expect(res['RejectedSendings']).to be_empty
    end
  end

  describe '.track_sending' do
    it 'should handle succesfull request' do
      @session.login('login', 'password')

      @session.stub(:send_request) do |req|
        response = double()
        response.stub(:body => {}.to_json)
        response
      end

      res = @session.track_sending('21121312')
    end
  end

  describe '.postamats' do
    it 'should handle succesfull request' do
      @session.login('login', 'password')

      @session.stub(:send_request) do |req|
        response = double()
        response.stub(:body => {}.to_json)
        response
      end

      @session.postamats
    end
  end

  describe '.make_label' do
    it 'should handle succesfull request' do
      @session.login('login', 'password')

      @session.stub(:send_request) do |req|
        response = double()
        response.stub(:body => "%PDF")
        response
      end

      @session.make_label('12345')
    end

    it 'should handle multiple invoices' do
      @session.login('login', 'password')

      @session.stub(:send_request) do |req|
        response = double()
        response.stub(:body => "%PDF")
        response
      end

      @session.make_label(['123123','123213'])

    end

    it 'should handle api error' do
      @session.login('login', 'password')

      @session.stub(:send_request) do |req|
        response = double()
        response.stub(:body => "Error: Случилось что-то ужасное")
        response
      end

      expect{@session.make_label(['123123'])}.to raise_error PickpointApi::Exceptions::ApiError
    end
  end

  describe '.make_reestr' do
    it 'should handle succesfull request' do
      @session.login('login', 'password')

      @session.stub(:send_request) do |req|
        response = double()
        response.stub(:body => "%PDF")
        response
      end

      @session.make_reestr('12345')
    end

    it 'should handle multiple invoices' do
      @session.login('login', 'password')

      @session.stub(:send_request) do |req|
        response = double()
        response.stub(:body => "%PDF")
        response
      end

      @session.make_reestr(['123123','123213'])

    end

    it 'should handle api error' do
      @session.login('login', 'password')

      @session.stub(:send_request) do |req|
        response = double()
        response.stub(:body => "Error: Случилось что-то ужасное")
        response
      end

      expect{@session.make_reestr(['123123'])}.to raise_error PickpointApi::Exceptions::ApiError
    end
  end

end
