# encoding: UTF-8

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

require "logger"
TEST_LOG_DIR = File.expand_path(File.dirname(__FILE__) + "/../log")
Hector.logger = Logger.new(File.open(TEST_LOG_DIR + "/test.log", "w+"))

require "hector/test_case"
require "hector/test_connection"
require "hector/test_deference"
require "hector/test_heartbeat"
require "hector/test_service"
require "hector/integration_test"

module Hector
  def self.fixture_path(filename)
    File.join(File.dirname(__FILE__), "fixtures", filename)
  end

  IDENTITY_FIXTURES = fixture_path("identities.yml")
  Identity.adapter = YamlIdentityAdapter.new(IDENTITY_FIXTURES)
end

