module PickpointApi

  def self.session login, password, hash = {}
    begin
      session = Session.new hash
      session.login login, password
      yield session
    rescue => ex
      raise PickpointApi::ApiError, ex.message
    ensure
      if session.present?
        session.logout
      end
    end
  end

end

require_relative('pickpoint_api/constants.rb')
require_relative('pickpoint_api/session.rb')
require_relative('pickpoint_api/exceptions.rb')
