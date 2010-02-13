begin
  require "hector"
  require "test/unit"
rescue LoadError => e
  if require "rubygems"
    retry
  else
    raise e
  end
end

module Hector
  class TestCase < Test::Unit::TestCase
    undef_method :default_test

    def self.test(name, &block)
      define_method("test #{name.inspect}", &block)
    end

    def connection
      Hector::Connection.new("test_#{rand}")
    end

    def identity(username = "username")
      Hector::Identity.new(username)
    end
  end
end
