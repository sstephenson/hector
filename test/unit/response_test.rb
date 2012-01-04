# encoding: UTF-8

require "test_helper"

module Hector
  class ResponseTest < TestCase
    test :"numeric response from the server" do
      assert_response ":hector.irc 001 sam :Welcome to IRC\r\n", "001", "sam", :text => "Welcome to IRC"
    end
    
    test :"response from a user" do
      assert_response ":ross!ross@hector.irc PRIVMSG sam :hello world\r\n", "PRIVMSG", "sam", :text => "hello world", :source => "ross!ross@hector.irc"
    end
    
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
