require "test_helper"

module Hector
  class ConnectionTest < TestCase
    test :"connecting without specifying a password shouldn't create a session" do
      c = connection
      c.receive_line "USER sam * 0 :Sam Stephenson"
      c.receive_line "NICK sam"
      assert_nil c.session
    end

    test :"connecting with an invalid password should respond with a 464" do
      c = connection
      c.receive_line "PASS invalid"
      c.receive_line "USER sam * 0 :Sam Stephenson"
      c.receive_line "NICK sam"
      assert_nil c.session
      assert c.sent_data[/^464 :/]
      assert c.connection_closed?
    end

    test :"connecting with a valid password should create a session" do
      c = connection
      c.receive_line "PASS secret"
      c.receive_line "USER sam * 0 :Sam Stephenson"
      c.receive_line "NICK sam"
      assert_not_nil c.session
      assert c.sent_data[/^001 sam :/]
      assert !c.connection_closed?
    end

    test :"sending an unknown command before registration should result in immediate disconnection" do
      c = connection
      c.receive_line "PASS secret"
      assert !c.connection_closed?
      c.receive_line "FOO"
      assert c.connection_closed?
    end

    test :"sending a command after registration should forward it to the session" do
      c = connection
      c.receive_line "PASS secret"
      c.receive_line "USER sam * 0 :Sam Stephenson"
      c.receive_line "NICK sam"
      c.session.expects(:on_foo)
      c.receive_line "FOO"
    end

    test :"sending QUIT after registration should result in disconnection" do
      c = connection
      c.receive_line "PASS secret"
      c.receive_line "USER sam * 0 :Sam Stephenson"
      c.receive_line "NICK sam"
      c.receive_line "QUIT"
      assert c.connection_closed?
    end

    test :"disconnecting should destroy the session" do
      c = connection
      c.receive_line "PASS secret"
      c.receive_line "USER sam * 0 :Sam Stephenson"
      c.receive_line "NICK sam"
      c.session.expects(:destroy)
      c.unbind
    end
  end
end
