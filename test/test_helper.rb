begin
  require "hector"
  require "test/unit"
  require "mocha"
rescue LoadError => e
  if require "rubygems"
    retry
  else
    raise e
  end
end

$:.unshift File.dirname(__FILE__) + "/lib"

require "hector/test_case"
require "hector/test_connection"
require "hector/integration_test"

module Hector
  def self.fixture_path(filename)
    File.join(File.dirname(__FILE__), "fixtures", filename)
  end

  IDENTITY_FIXTURES = fixture_path("identities.yml")
  Identity.filename = IDENTITY_FIXTURES
end
