require "test_helper"

module Hector
  class SessionTest < TestCase
    def setup
      Session.reset!
    end

    test :"creating a session adds it to the session pool" do
      assert_equal [], Session.sessions

      first = Session.create(connection, identity, "first")
      assert_equal [first], Session.sessions

      second = Session.create(connection, identity, "second")
      assert_equal [first, second], Session.sessions
    end

    test :"destroying a session removes it from the session pool" do
      assert_equal [], Session.sessions

      first = Session.create(connection, identity, "first")
      second = Session.create(connection, identity, "second")
      assert_equal [first, second], Session.sessions
      
      first.destroy
      assert_equal [second], Session.sessions
    end
  end
end
