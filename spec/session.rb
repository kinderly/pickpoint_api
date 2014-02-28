require_relative '../lib/pickpoint_api.rb'

describe ::PickpointApi::Session do
  before do
    ::PickpointApi::Session.any_instance.stub(:send_request) do |req|
      nil
    end
  end

  it 'can instatiate' do
    session = ::PickpointApi::Session.new(test: true)
    expect(session).not_to be_nil
    expect(session.test).to eq true
    expect(session.state).to eq :new
  end

  describe '.login' do
    it 'should log-in' do
      session = ::PickpointApi::Session.new(test: true)

      session.stub(:send_request) do |req|
        response = double()
        response.stub(:body => {
            'SessionId' => '111111111'
          }.to_json)
        response
      end

      session.login('login', 'password')
      expect(session.state).to eq :started
    end

    it 'should handle incorrect login' do
      session = ::PickpointApi::Session.new(test: true)

      session.stub(:send_request) do |req|
        response = double()
        response.stub(:body => {
            'ErrorMessage' => 'Неверный логин или пароль'
          }.to_json)
        response
      end

      expect { session.login('login', 'password') }.to raise_error ::PickpointApi::Exceptions::ApiError
    end
  end

end
