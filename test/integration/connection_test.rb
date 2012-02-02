# encoding: UTF-8

require "test_helper"

module Hector
  class ConnectionTest < IntegrationTest
    test :"connecting without specifying a password shouldn't create a session" do
      connection.tap do |c|
        user! c
        nick! c

        assert_nil c.session
      end
    end

    test :"connecting with an invalid password should respond with a 464" do
      connection.tap do |c|
        pass! c, "invalid"
        user! c
        nick! c

        assert_nil c.session
        assert_invalid_password c
        assert_closed c
      end
    end

    test :"connecting with a valid password should create a session" do
      authenticated_connection.tap do |c|
        assert_not_nil c.session
        assert_welcomed c
        assert_not_closed c
      end
    end
    
    test :"sending a concatenated username and password with PASS should create a session" do
      connection.tap do |c|
        pass! c, "sam:secret"
        user! c
        nick! c
        
        assert_not_nil c.session
        assert_welcomed c
        assert_not_closed c
      end
    end
    
    test :"sending a username and password with PASS should create a session even if USER credentials are incorrect" do
      connection.tap do |c|
        pass! c, "sam:secret"
        user! c, "invalid"
        nick! c
        
        assert_not_nil c.session
        assert_welcomed c
        assert_not_closed c
      end
    end
    
    test :"sending an invalid concatenated username and password with PASS should respond with a 464" do
      connection.tap do |c|
        pass! c, "sam:invalid"
        user! c
        nick! c
        
        assert_nil c.session
        assert_invalid_password c
        assert_closed c
      end
    end

    test :"sending an unknown command before registration should result in immediate disconnection" do
      connection.tap do |c|
        pass! c
        assert_not_closed c
        c.receive_line "FOO"
        assert_closed c
      end
    end
    
    test :"sending CAP before registration should be ignored" do
      connection.tap do |c|
        c.receive_line "CAP LS"
        assert_not_closed c
        
        pass! c
        user! c
        nick! c
        assert_welcomed c
      end
    end

    test :"sending a command after registration should forward it to the session" do
      authenticated_connection.tap do |c|
        c.session.expects(:on_foo)
        c.receive_line "FOO"
      end
    end

    test :"sending QUIT after registration should result in disconnection" do
      authenticated_connection.tap do |c|
        c.receive_line "QUIT"
        assert_closed c
      end
    end

    test :"disconnecting should destroy the session" do
      authenticated_connection.tap do |c|
        c.session.expects(:destroy)
        c.unbind
      end
    end

    test :"two connections can't use the same nickname" do
      c1 = authenticated_connection("sam")
      assert_welcomed c1

      c2 = authenticated_connection("sam")
      assert_nickname_in_use c2
      assert_nil c2.session
      assert_not_closed c2
    end

    test :"disconnecting frees the nickname for future use" do
      c1 = authenticated_connection("sam")
      c1.unbind

      c2 = authenticated_connection("sam")
      assert_welcomed c2
    end

    test :"sending the ping command should respond with a pong" do
      authenticated_connection.tap do |c|
        c.receive_line "PING 12345"
        assert_sent_to c, ":hector.irc PONG hector.irc :12345"
      end
    end

    test :"quitting should respond with an error" do
      authenticated_connection.tap do |c|
        c.receive_line "QUIT :bye"
        assert_sent_to c, "ERROR :Closing Link: sam[hector] (Quit: bye)"
      end
    end

    test :"sending a privmsg should reset idle time" do
      authenticated_connection.tap do |c|
        sleep 1
        assert_not_equal 0, c.session.seconds_idle
        c.receive_line "PRIVMSG joe :hey testing"
        sleep 1
        assert_not_equal 0, c.session.seconds_idle
        assert c.session.seconds_idle < 2
      end
    end

    test :"nicknames can be changed" do
      authenticated_connection("sam").tap do |c|
        c.receive_line "NICK joe"
        assert_sent_to c, ":sam NICK joe"
        c.receive_line "NICK jöe"
        assert_sent_to c, ":joe NICK jöe"
      end
    end
    
    test :"changing to a new nickname coerces it to UTF-8" do
      authenticated_connection("sam").tap do |c|
        c.receive_line "NICK säm".force_encoding("ASCII-8BIT")
        c.receive_line "NICK lée".force_encoding("ASCII-8BIT")
        c.receive_line "NICK røss".force_encoding("ASCII-8BIT")
        
        assert_sent_to c, ":sam NICK säm"
        assert_sent_to c, ":säm NICK lée"
        assert_sent_to c, ":lée NICK røss"
      end
    end if String.method_defined?(:force_encoding)

    test :"changing to an invalid nickname should respond with 432" do
      authenticated_connection("sam").tap do |c|
        c.receive_line "NICK $"
        assert_erroneous_nickname c, "$"
      end
    end

    test :"changing to a nickname that's already in use should respond with 433" do
      authenticated_connections do |c1, c2|
        c2.receive_line "NICK user1"
        assert_nickname_in_use c2, "user1"
      end
    end

    test :"away messages can be changed" do
      authenticated_connection("sam").tap do |c|
        c.receive_line "AWAY :bai guys"
        assert_sent_to c, ":hector.irc 306 :You have been marked as being away"
        c.receive_line "AWAY"
        assert_sent_to c, ":hector.irc 305 :You are no longer marked as being away"
      end
    end
  end
end
