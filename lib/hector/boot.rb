require "pathname"
require "logger"

module Hector
  class << self
    attr_accessor :lib, :root

    def init_app
      set_root!
      load Hector.root.join("init.rb")
    end

    def set_root!
      if root = ENV["HECTOR_ROOT"]
        Hector.root = Pathname.new(File.expand_path(root))
      else
        dir = Pathname.new(Dir.pwd)
        dir = dir.parent while dir != dir.parent && dir.basename.to_s !~ /\.hect$/
        abort "error: please specify HECTOR_ROOT" if dir == dir.parent
        Hector.root = dir
      end
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
