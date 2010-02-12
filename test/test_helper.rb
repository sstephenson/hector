require "test/unit"
require "hector"

module Hector
  class TestCase < Test::Unit::TestCase
    undef_method :default_test

    def self.test(name, &block)
      define_method("test #{name.inspect}", &block)
    end
  end
end
