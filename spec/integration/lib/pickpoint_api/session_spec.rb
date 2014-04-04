require_relative '../../../spec_helper'

describe 'PickpointApi::Session' do

  before (:all) do
    @session = PickpointApi.test_session
  end

  after (:all) do
    @session.logout
  end

  describe '#login' do

    it 'should log in' do

    end

    it 'should raise on incorrect credentials' do
      session = PickpointApi::Session.new(test: true)
      expect{session.login('wrong', 'password')}.to raise_error PickpointApi::Exceptions::LoginError
    end

  end

  describe '#logout' do

    it 'should log out' do
      session = PickpointApi.test_session
      session.logout
      expect(session.state).to eq :closed
    end

  end


  describe '#city_list' do

    it 'should work' do
      city_list = @session.city_list
      expect(city_list).not_to be_empty
    end

  end

  describe '#postamat_list' do

    it 'should work' do
      postamat_list = @session.postamat_list
      expect(postamat_list).not_to be_empty
    end

  end



end
