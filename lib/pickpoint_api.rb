require('logger')

module PickpointApi
  VERSION = "0.1"

  @logger = Logger.new($stdout)
  @logger.level = Logger::INFO

  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    @logger
  end

  def self.session login, password, hash = {}
    begin
      session = Session.new hash
      session.login login, password
      yield session
    rescue => ex
      raise ::PickpointApi::Exceptions::ApiError, ex.message
    ensure
      if !session.nil? && session.state == :started
        session.logout
      end
    end
  end

end

require_relative('pickpoint_api/exceptions.rb')
require_relative('pickpoint_api/constants.rb')
require_relative('pickpoint_api/session.rb')


