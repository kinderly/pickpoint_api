module PickpointApi::Exceptions

  ApiError = Class.new(StandardError)
  InvalidSessionState = Class.new(ApiError)
  LoginError = Class.new(ApiError)
  LogoutError = Class.new(ApiError)
  UnknownApiAction = Class.new(ApiError)
  CourierError = Class.new(ApiError)
end
