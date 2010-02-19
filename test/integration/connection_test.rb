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

    test :"sending an unknown command before registration should result in immediate disconnection" do
      connection.tap do |c|
        pass! c
        assert_not_closed c
        c.receive_line "FOO"
        assert_closed c
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
  end
end
