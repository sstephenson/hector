require "test_helper"

module Hector
  class ConnectionTest < TestCase
    def teardown
      Session.reset!
    end

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
      assert_not_closed c2
    end

    test :"disconnecting frees the nickname for future use" do
      c1 = authenticated_connection("sam")
      c1.unbind

      c2 = authenticated_connection("sam")
      assert_welcomed c2
    end

    def authenticated_connection(nickname = "sam")
      connection.tap do |c|
        authenticate! c, nickname
      end
    end

    def authenticate!(connection, nickname)
      pass! connection
      user! connection
      nick! connection, nickname
    end

    def pass!(connection, password = "secret")
      connection.receive_line("PASS #{password}")
    end

    def user!(connection, username = "sam", realname = "Sam Stephenson")
      connection.receive_line("USER #{username} * 0 :#{realname}")
    end

    def nick!(connection, nickname = "sam")
      connection.receive_line("NICK #{nickname}")
    end

    def connection_nickname(connection)
      connection.instance_variable_get(:@nickname)
    end

    def assert_welcomed(connection)
      assert connection.sent_data[/^001 #{connection_nickname(connection)} :/]
    end

    def assert_invalid_password(connection)
      assert connection.sent_data[/^464 :/]
    end

    def assert_nickname_in_use(connection)
      assert connection.sent_data[/^433 #{connection_nickname(connection)} :/]
    end

    def assert_closed(connection)
      assert connection.connection_closed?
    end

    def assert_not_closed(connection)
      assert !connection.connection_closed?
    end
  end
end
