require "pathname"
require "logger"

module Hector
  class << self
    attr_accessor :lib, :root

    def start
      raise LoadError, "please specify HECTOR_ROOT" unless Hector.root
      load_defaults
      load_application
    end

    def load_root
      if root = ENV["HECTOR_ROOT"]
        Hector.root = Pathname.new(File.expand_path(root))
      else
        Hector.root = find_application_root_from(Dir.pwd)
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

    def find_application_root_from(working_directory)
      dir = Pathname.new(working_directory)
      dir = dir.parent while dir != dir.parent && dir.basename.to_s !~ /\.hect$/
      dir == dir.parent ? nil : dir
    end
  end
end

Hector.lib = Pathname.new(File.expand_path(File.dirname(__FILE__) + "/.."))
Hector.load_root

if Hector.root
  vendor_lib = Hector.root.join("vendor/hector/lib")
  Hector.lib = vendor_lib if vendor_lib.exist?
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
