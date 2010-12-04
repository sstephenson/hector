spec = Gem::Specification.new do |s|
  s.name         = "hector"
  s.version      = "1.0.0"
  s.platform     = Gem::Platform::RUBY
  s.authors      = ["Sam Stephenson"]
  s.email        = ["sstephenson@gmail.com"]
  s.homepage     = "http://github.com/sstephenson/hector"
  s.summary      = "Private group chat server"
  s.description  = "A private group chat server for people you trust. Implements a limited subset of the IRC protocol."
  s.files        = Dir["lib/**/*.rb"]
  s.require_path = "lib"

  s.add_dependency "eventmachine", ">=0.12.10"
  s.add_development_dependency "mocha", ">=0.9.9"
end
