require "pathname"
require "logger"

module Hector
  class << self
    attr_accessor :lib, :root
  end

  self.lib = Pathname.new(File.dirname(__FILE__) + "/..")
end

$:.unshift Hector.lib

begin
  require "hector"
rescue LoadError => e
  if require "rubygems"
    retry
  else
    raise e
  end
end

Hector.root = Pathname.new(ENV["HECTOR_ROOT"] || Hector.lib.join(".."))
Hector.logger = Logger.new($stderr)
Hector.logger.datetime_format = "%Y-%m-%d %H:%M:%S"

Hector::Identity.adapter = Hector::YamlIdentityAdapter.new(
  Hector.root.join("config/identities.yml")
)
