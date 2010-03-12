require "test_helper"

module Hector
  class SessionTest < TestCase
    def teardown
      Session.reset!
    end

    test :"creating a session adds it to the session pool" do
      assert_equal [], session_names

      create_session("first")
      assert_equal ["first"], session_names

      create_session("second")
      assert_equal ["first", "second"], session_names
    end

    test :"destroying a session removes it from the session pool" do
      assert_equal [], session_names

      first = create_session("first")
      second = create_session("second")
      assert_equal ["first", "second"], session_names

      first.destroy
      assert_equal ["second"], session_names
    end

    test :"nicknames must be valid" do
      ["", "-", "foo bar"].each do |nickname|
        assert_raises(ErroneousNickname) do
          create_session(nickname)
        end
      end
    end

    test :"two sessions can't have the same nickname" do
      create_session("sam")
      assert_raises(NicknameInUse) do
        create_session("sam")
      end
    end

    test :"nicknames are case-insensitive" do
      create_session("sam")
      assert_raises(NicknameInUse) do
        create_session("SAM")
      end
    end

    test :"nicknames preserve their original case" do
      create_session("Sam")
      assert_equal "Sam", Session.find("sam").nickname
    end

    test :"idle time increases beginning with initial connection" do
      session = create_session("clint")
      sleep 1
      assert_not_equal 0, session.seconds_idle
    end

    test :"sessions can be renamed" do
      session = create_session("sam")
      assert_equal "sam", session.nickname

      session.rename("joe")
      assert_equal "joe", session.nickname

      assert_nil Session.find("sam")
      assert_equal session, Session.find("joe")
    end

    test :"sessions can't be renamed to invalid nicknames" do
      session = create_session("sam")

      assert_raises(ErroneousNickname) do
        session.rename("$")
      end

      assert_equal "sam", session.nickname
      assert_equal session, Session.find("sam")
    end

    test :"sessions can't be renamed to a nickname already in use" do
      first = create_session("first")
      second = create_session("second")

      assert_raises(NicknameInUse) do
        second.rename("first")
      end

      assert_equal "second", second.nickname
      assert_equal first, Session.find("first")
      assert_equal second, Session.find("second")
    end

    test :"sessions can have unicode nicknames" do
      session1 = create_session("I♥")
      session2 = create_session("яблочный")
      session3 = create_session("quảtáo")
      session4 = create_session("☬☃☢☠☆☆☆")

      assert_equal "I♥", session1.nickname
      assert_equal "яблочный", session2.nickname
      assert_equal "quảtáo", session3.nickname
      assert_equal "☬☃☢☠☆☆☆", session4.nickname

      assert_equal session1, Session.find("I♥")
      assert_equal session2, Session.find("яблочный")
      assert_equal session3, Session.find("quảtáo")
      assert_equal session4, Session.find("☬☃☢☠☆☆☆")
    end

    def create_session(nickname)
      UserSession.create(nickname, connection, identity, "Real Name")
    end

    def session_names
      Session.nicknames.sort
    end
  end
end
