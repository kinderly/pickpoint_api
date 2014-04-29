require 'coveralls'
Coveralls.wear!

require 'faker'
require 'factory_girl'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end

require_relative './support/dummy_data.rb'
require_relative './support/http_mocking.rb'
require_relative '../lib/pickpoint_api.rb'

