require File.expand_path("../lib/pickpoint_api/version", __FILE__)

Gem::Specification.new do |s|
  s.name = "pickpoint_api"
  s.version = ::PickpointApi::VERSION
  s.authors = ["Kinderly LTD"]
  s.email = ["nuinuhin@gmail.com"]
  s.homepage = "http://github.com/kinderly/pickpoint_api"

  s.summary = %q{A wrapper for Pickpoint API}
  s.description = %q{This gem provides a Ruby wrapper over Pickpoint API.}
  s.license = "MIT"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
end
