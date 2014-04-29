# coding: utf-8
require_relative '../../../spec_helper'

describe 'PickpointApi::Session' do

  before (:all) do
    PickpointApi.logger.level = Logger::INFO
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

  describe '#get_states' do
    it 'should work' do
      states = @session.get_states
      expect(states).not_to be_empty
    end
  end

  describe '#get_invoices_change_state' do
    it 'should work' do
      states = @session.get_states
      states.sample(3).each do |state|
        list = @session.get_invoices_change_state(state['State'], Time.now - 10 * 24 * 3600)
      end
    end
  end

  describe '#postamat_list' do
    it 'should work' do
      postamat_list = @session.postamat_list
      expect(postamat_list).not_to be_empty
    end
  end

  describe '#get_zone' do
    it 'should work without PT' do
      zones = @session.get_zone('Москва')
      expect(zones['Error']).to be_nil
      expect(zones['Zones']).not_to be_empty
    end

    it 'should work with PT' do
      postamat_list = @session.postamat_list

      postamat_list.sample(1).each do |postamat|
        zones = @session.get_zone('Москва', postamat['Id'])
      end
    end
  end

  describe '#get_return_invoices_list' do
    it 'should work' do
      return_invoices_list = @session.get_return_invoices_list(Time.now - 365 * 24 * 3600)
      expect(return_invoices_list['ErrorMessage']).to be_nil
    end
  end

end
