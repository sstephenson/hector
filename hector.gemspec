spec = Gem::Specification.new do |s|
  s.name         = "hector"
  s.version      = "1.0.9"
  s.platform     = Gem::Platform::RUBY
  s.authors      = ["Sam Stephenson", "Ross Paffett"]
  s.email        = ["sstephenson@gmail.com", "ross@rosspaffett.com"]
  s.homepage     = "http://github.com/sstephenson/hector"
  s.summary      = "Private group chat server"
  s.description  = "A private group chat server for people you trust. Implements a limited subset of the IRC protocol."
  s.license      = "MIT"
  s.files        = Dir["lib/**/*.rb"]
  s.require_path = "lib"
  s.executables  = ["hector", "hector-daemon", "hector-identity", "hector-setup"]

  s.add_runtime_dependency "eventmachine", "~> 1.0", ">= 1.0.3"
  s.add_development_dependency "mocha", "~> 1.0"
end
