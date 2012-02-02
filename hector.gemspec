spec = Gem::Specification.new do |s|
  s.name         = "hector"
  s.version      = "1.0.8"
  s.platform     = Gem::Platform::RUBY
  s.authors      = ["Sam Stephenson", "Ross Paffett"]
  s.email        = ["sstephenson@gmail.com", "ross@rosspaffett.com"]
  s.homepage     = "http://github.com/sstephenson/hector"
  s.summary      = "Private group chat server"
  s.description  = "A private group chat server for people you trust. Implements a limited subset of the IRC protocol."
  s.files        = Dir["lib/**/*.rb"]
  s.require_path = "lib"
  s.executables  = ["hector", "hector-daemon", "hector-identity", "hector-setup"]

  s.add_dependency "eventmachine", ">=0.12.10"
  s.add_development_dependency "mocha", ">=0.9.9"
end
