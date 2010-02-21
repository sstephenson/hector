require "test_helper"

module Hector
  class SessionTest < TestCase
    def teardown
      Session.reset!
    end

    test :"creating a session adds it to the session pool" do
      assert_equal [], session_names

      Session.create("first", connection, identity, 'First Realname')
      assert_equal ["first"], session_names

      Session.create("second", connection, identity, 'Second Realname')
      assert_equal ["first", "second"], session_names
    end

    test :"destroying a session removes it from the session pool" do
      assert_equal [], session_names

      first = Session.create("first", connection, identity, 'First Realname')
      second = Session.create("second", connection, identity, 'Second Realname')
      assert_equal ["first", "second"], session_names
      
      first.destroy
      assert_equal ["second"], session_names
    end

    test :"nicknames must be valid" do
      ["", "-", "foo bar"].each do |nickname|
        assert_raises(ErroneousNickname) do
          Session.create(nickname, connection, identity, 'Realnames')
        end
      end
    end

    test :"two sessions can't have the same nickname" do
      Session.create("sam", connection, identity, 'My Realname')
      assert_raises(NicknameInUse) do
        Session.create("sam", connection, identity, 'My Realname')
      end
    end

    test :"nicknames are case-insensitive" do
      Session.create("sam", connection, identity, 'Sam Stephenson')
      assert_raises(NicknameInUse) do
        Session.create("SAM", connection, identity, 'SAM STEPHENSON')
      end
    end

    test :"nicknames preserve their original case" do
      Session.create("Sam", connection, identity, 'Sam Stephenson')
      assert_equal "Sam", Session.find("sam").nickname
    end

    test :"idle time increases beginning with initial connection" do
      first = Session.create("clint", connection, identity, 'Clint Ecker')
      sleep 1
      assert_not_equal first.idle, 0
    end

    def session_names
      Session.nicknames.sort
    end
  end
end
