require "test_helper"

module Hector
  class TestError < IrcError("FOO", :text => "This is a test"); end
  class FatalError < IrcError("FATAL", :fatal => true); end

  class IrcErrorTest < TestCase
    test :"raising an IrcError without an argument" do
      exception = begin
        raise TestError
      rescue Exception => e
        e
      end

      assert_equal "FOO :This is a test\r\n", exception.response.to_s
      assert !exception.fatal?
    end

    test :"raising an IrcError with an argument" do
      exception = begin
        raise TestError, "bar"
      rescue Exception => e
        e
      end

      assert_equal "FOO bar :This is a test\r\n", exception.response.to_s
      assert !exception.fatal?
    end

    test :"raising a fatal IrcError" do
      exception = begin
        raise FatalError
      rescue Exception => e
        e
      end

      assert_equal "FATAL\r\n", exception.response.to_s
      assert exception.fatal?
    end
  end
end
