require "test_helper"

module Hector
  class RequestTest < TestCase
    test :"empty line" do
      assert_request :command => "", :args => [], :text => nil, :line => ""
      assert_request :command => "", :args => [], :text => nil, :line => " "
    end

    test :"just a command" do
      assert_request :command => "QUIT", :args => [], :text => nil, :line => "QUIT"
      assert_request :command => "QUIT", :args => [], :text => nil, :line => "QUIT "
      assert_request :command => "QUIT", :args => [], :text => nil, :line => " QUIT"
      assert_request :command => "QUIT", :args => [], :text => nil, :line => "quit"
    end

    test :"a command with text but no arguments" do
      assert_request :command => "QUIT", :args => [], :text => "foo", :line => "QUIT :foo"
      assert_request :command => "QUIT", :args => [], :text => "foo bar", :line => "QUIT :foo bar"      
      assert_request :command => "QUIT", :args => ["foo"], :text => "foo", :line => "QUIT foo"
      assert_request :command => "QUIT", :args => [], :text => "", :line => "QUIT :"
    end

    test :"a command with arguments" do
      assert_request :command => "JOIN", :args => ["#channel"], :line => "JOIN #channel"
      assert_request :command => "JOIN", :args => ["#channel", "key"], :line => "JOIN #channel key"
    end

    test :"a command with text and arguments" do
      assert_request :command => "PRIVMSG", :args => ["nickname"], :text => "message", :line => "PRIVMSG nickname :message"
      assert_request :command => "PRIVMSG", :args => ["nickname"], :text => "message with spaces", :line => "PRIVMSG nickname :message with spaces"
      assert_request :command => "PRIVMSG", :args => ["nickname", "message"], :text => "message", :line => "PRIVMSG nickname message"
    end

    def assert_request(options)
      request = Request.new(options.delete(:line))
      options.each do |method, value|
        assert_equal value, request.send(method), "when calling method #{method.inspect}"
      end
    end
  end
end
