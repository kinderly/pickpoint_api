require_relative '../spec_helper.rb'

include DummyData

describe ::PickpointApi::Session do

  before(:each) do
    ::HttpMocking.clear_response_queue
    @session = ::PickpointApi::Session.new(test: true)
    ::HttpMocking.enqueue_response(LOGIN_SUCCESSFUL)
    @session.login('login', 'password')
  end

  it 'should create instance' do
    @session = ::PickpointApi::Session.new(test: true)
    expect(@session).not_to be_nil
    expect(@session.test).to eq true
    expect(@session.state).to eq :new
  end

  it 'should raise error on invalid session state' do
    ::HttpMocking.enqueue_response(LOGOUT_SUCCESSFUL)
    @session.logout
    expect {@session.city_list}.to raise_error ::PickpointApi::Exceptions::InvalidSessionStateError
  end

  describe '.login' do
    it 'should log-in' do
      expect(@session.state).to eq :started
    end

    it 'should handle incorrect login' do
      @session = ::PickpointApi::Session.new(test: true)
      ::HttpMocking.enqueue_response(LOGIN_FAILED)
      expect { @session.login('login', 'password') }.to raise_error ::PickpointApi::Exceptions::LoginError
      expect(@session.state).to eq(:error)
    end
  end

  describe '.logout' do
    it 'should log out' do
      ::HttpMocking.enqueue_response(LOGOUT_SUCCESSFUL)
      @session.logout
      expect(@session.state).to eq(:closed)
    end

    it 'should raise error on logout fail' do
      ::HttpMocking.enqueue_response(LOGOUT_FAIL)
      expect{@session.logout}.to raise_error ::PickpointApi::Exceptions::LogoutError
      expect(@session.state).to eq(:error)
    end
  end

  describe '.create_sending' do
    it 'should handle successfull request' do
      ::HttpMocking.enqueue_response(CREATE_SENDING_SUCCESSFUL)
      res = @session.create_sending(SAMPLE_SENDING_REQUEST)
      expect(res['CreatedSendings']).not_to be_empty
      expect(res['RejectedSendings']).to be_empty
    end
  end

  [:track_sending, :sending_info].each do |m|
    describe ".#{m}" do
      it 'should handle successfull request' do
        ::HttpMocking.enqueue_response({}.to_json)
        res = @session.send(m, '21121312')
      end
    end
  end

  [:make_label, :make_zlabel, :make_reestr].each do |m|
    describe ".#{m}" do
      it 'should handle successfull request' do
        ::HttpMocking.enqueue_response(PDF_SUCCESS)
        @session.send(m, '12345')
      end

      it 'should handle multiple invoices' do
        ::HttpMocking.enqueue_response(PDF_SUCCESS)
        @session.send(m, ['123123','123213'])
      end

      it 'should handle api error' do
        ::HttpMocking.enqueue_response(PDF_ERROR)
        expect{@session.send(m, ['123123'])}.to raise_error PickpointApi::Exceptions::ApiError
      end
    end
  end

  describe '.city_list' do
    it 'should handle successfull request' do
      ::HttpMocking.enqueue_response(CITY_LIST_SUCCESS)
      res = @session.city_list
      expect(res.count).to eq(2)
    end
  end

  describe '.get_states' do
    it 'should handle successfull request' do
      ::HttpMocking.enqueue_response(STATES_SUCCESS)
      res = @session.get_states
      expect(res.count).to eq(3)
    end
  end

  describe '.postamat_list' do
    it 'should handle successfull request' do
      ::HttpMocking.enqueue_response({}.to_json)
      @session.postamat_list
    end
  end

  describe '.get_zone' do
    it 'should handle successfull request' do
      ::HttpMocking.enqueue_response(ZONES_SUCCESS)
      res = @session.get_zone('Some city', '7801-035')
      expect(res['Error']).to be_nil
    end
  end

  describe '.get_invoices_change_state' do
    it 'should handle successfull request' do
      ::HttpMocking.enqueue_response(GET_STATE_SUCCESS)
      res = @session.get_invoices_change_state(102, DateTime.parse('2014-01-01'), DateTime.parse('2014-03-01'))
      expect(res.count).to eq(1)
    end
  end

  describe '.courier' do
    it 'should handle successfull request' do
      ::HttpMocking.enqueue_response('{}')
      res = @session.courier({})
    end
  end

end
