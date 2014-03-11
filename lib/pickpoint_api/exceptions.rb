module PickpointApi::Exceptions

  ApiError = Class.new(StandardError)
  InvalidSessionStateError = Class.new(ApiError)
  LoginError = Class.new(ApiError)
  LogoutError = Class.new(ApiError)
  UnknownApiActionError = Class.new(ApiError)
  CourierError = Class.new(ApiError)
end
