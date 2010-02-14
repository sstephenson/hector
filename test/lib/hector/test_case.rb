module Hector
  class TestCase < Test::Unit::TestCase
    undef_method :default_test

    def self.test(name, &block)
      define_method("test #{name.inspect}", &block)
    end

    def connection
      Hector::TestConnection.new("test")
    end

    def identity(username = "sam")
      Hector::Identity.find(username)
    end
  end
end
