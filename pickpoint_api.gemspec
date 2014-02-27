Gem::Specification.new do |s|
  s.name = "pickpoint_api"
  s.version = "0.0.1"
  s.authors = ["Kinderly LTD"]
  s.email = ["nuinuhin@gmail.com"]
  s.homepage = "http://github.com/kinderly/pickpoint_api"

  s.summary = %q{A wrapper for Pickpoint API}
  s.description = %q{A wrapper for Pickpoint API}
  s.license = "MIT"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
end
