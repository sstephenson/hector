module Hector
  class TestCase < Test::Unit::TestCase
    undef_method :default_test

    def self.test(name, &block)
      define_method("test #{name.inspect}", &block)
    end

    def run_with_logging(result, &block)
      Hector.logger.info "--- #@method_name ---"
      run_without_logging(result, &block)
      Hector.logger.info " "
    end

    alias_method :run_without_logging, :run
    alias_method :run, :run_with_logging

    def connection
      Hector::TestConnection.new("test")
    end

    def identity(username = "sam")
      Hector::Identity.find(username)
    end
  end
end
