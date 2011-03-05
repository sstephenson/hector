module Hector
  class TestCase < Test::Unit::TestCase
    undef_method :default_test if method_defined?(:default_test)

    def self.test(name, &block)
      define_method("test #{name.inspect}", &block)
    end

    def run(*)
      Hector.logger.info "--- #@method_name ---"
      super
    ensure
      Hector.logger.info " "
    end

    def sleep(seconds)
      current_time = Time.now
      Time.expects(:now).at_least_once.returns(current_time + seconds)
    end

    def connection
      Hector::TestConnection.new("test")
    end

    def identity(username = "sam")
      Hector::Identity.new(username)
    end
  end
end
