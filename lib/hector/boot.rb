require "pathname"
require "logger"

module Hector
  class << self
    attr_accessor :lib, :root

    def start
      load_root
      load_defaults
      load_application
    end

    def load_root
      if root = ENV["HECTOR_ROOT"]
        Hector.root = Pathname.new(File.expand_path(root))
      else
        dir = Pathname.new(Dir.pwd)
        dir = dir.parent while dir != dir.parent && dir.basename.to_s !~ /\.hect$/
        raise LoadError, "please specify HECTOR_ROOT" if dir == dir.parent
        Hector.root = dir
      end
    end

    def load_defaults
      log_path = Hector.root.join("log/hector.log")
      Hector.logger = Logger.new(log_path)
      Hector.logger.datetime_format = "%Y-%m-%d %H:%M:%S"

      identities_path = Hector.root.join("config/identities.yml")
      Hector::Identity.adapter = Hector::YamlIdentityAdapter.new(identities_path)
    end

    def load_application
      $:.unshift Hector.root.join("lib")
      load Hector.root.join("init.rb")
    end
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
