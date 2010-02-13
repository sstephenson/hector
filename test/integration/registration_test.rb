require "test_helper"

module Hector
  class RegistrationTest < TestCase
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
  end
end
