require('logger')

module PickpointApi
  @logger = Logger.new($stdout)
  @logger.level = Logger::INFO

  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    @logger
  end

  def self.session login, password, hash = {}
    session = Session.new hash
    session.login(login, password)
    if block_given?
      begin
        yield session
      rescue => ex
        raise ::PickpointApi::Exceptions::ApiError, ex.message
      ensure
        if !session.nil? && session.state == :started
          session.logout
        end
      end
    else
      session
    end
  end

  def self.test_session(&block)
    if block_given?
      session('apitest', 'apitest', test: true, &block)
    else
      session('apitest', 'apitest', test: true)
    end
  end

end

require_relative('pickpoint_api/exceptions.rb')
require_relative('pickpoint_api/constants.rb')
require_relative('pickpoint_api/session.rb')
require_relative('pickpoint_api/label.rb')


