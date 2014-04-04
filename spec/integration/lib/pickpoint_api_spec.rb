require_relative '../../spec_helper'

describe 'PickpointApi' do

  describe '::test_session' do

    it 'should work without block' do
      session = PickpointApi::test_session
    end

    it 'should work with block' do
      PickpointApi::test_session do |s|
        expect(s.state).to eq :started
      end
    end
  end

end
