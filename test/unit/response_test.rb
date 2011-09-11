# encoding: UTF-8

require "test_helper"

module Hector
  class ResponseTest < TestCase
    test :"a nickname and message with mixed encodings" do
      assert_response ":røss!ross@hector.irc PRIVMSG sam :hello world\r\n", "PRIVMSG", "sam", :text => "hello world", :source => "røss!ross@hector.irc".force_encoding("ASCII-8BIT")
      assert_response ":røss!ross@hector.irc PRIVMSG sam :hey there ☞\r\n", "PRIVMSG", "sam", :text => "hey there ☞", :source => "røss!ross@hector.irc".force_encoding("ASCII-8BIT")
    end
    
    def assert_response(line, *args)
      response = Response.new(*args)
      assert_equal line, response.to_s
    end
  end
end
