require "test_helper"

module Hector
  class MessagingTest < IntegrationTest
    test :"messages can be sent between two sessions" do
      authenticated_connections do |c1, c2|
        c1.receive_line "PRIVMSG user2 :hello world"
        assert_sent_to c2, ":user1!sam@hector.irc PRIVMSG user2 :hello world"
      end
    end

    test :"notices can be sent between two sessions" do
      authenticated_connections do |c1, c2|
        c1.receive_line "NOTICE user2 :hello world"
        assert_sent_to c2, ":user1!sam@hector.irc NOTICE user2 :hello world"
      end
    end

    test :"sending a message to a nonexistent session should result in a 401" do
      authenticated_connection.tap do |c|
        c.receive_line "PRIVMSG clint :hi clint"
        assert_no_such_nick_or_channel c, "clint"
      end
    end

    test :"sending a notice to a nonexistent session should result in a 401" do
      authenticated_connection.tap do |c|
        c.receive_line "NOTICE clint :hi clint"
        assert_no_such_nick_or_channel c, "clint"
      end
    end

    test :"sending a message to a nonexistent channel should respond with a 401" do
      authenticated_connection.tap do |c|
        c.receive_line "PRIVMSG #test :hello"
        assert_no_such_nick_or_channel c, "#test"
      end
    end

    test :"sending a notice to a nonexistent channel should respond with a 401" do
      authenticated_connection.tap do |c|
        c.receive_line "NOTICE #test :hello"
        assert_no_such_nick_or_channel c, "#test"
      end
    end

    test :"sending a message to an unjoined channel should respond with a 404" do
      authenticated_connections do |c1, c2|
        c1.receive_line "JOIN #test"
        c2.receive_line "PRIVMSG #test :hello"
        assert_cannot_send_to_channel c2, "#test"
      end
    end

    test :"sending a notice to an unjoined channel should respond with a 404" do
      authenticated_connections do |c1, c2|
        c1.receive_line "JOIN #test"
        c2.receive_line "NOTICE #test :hello"
        assert_cannot_send_to_channel c2, "#test"
      end
    end

    test :"sending a message to a joined channel should broadcast it to everyone except the sender" do
      authenticated_connections(:join => "#test") do |c1, c2, c3|
        assert_nothing_sent_to(c1) { c1.receive_line "PRIVMSG #test :hello" }
        assert_sent_to c2, ":user1!sam@hector.irc PRIVMSG #test :hello"
        assert_sent_to c3, ":user1!sam@hector.irc PRIVMSG #test :hello"
      end
    end

    test :"sending a notice to a joined channel should broadcast it to everyone except the sender" do
      authenticated_connections(:join => "#test") do |c1, c2, c3|
        assert_nothing_sent_to(c1) { c1.receive_line "NOTICE #test :hello" }
        assert_sent_to c2, ":user1!sam@hector.irc NOTICE #test :hello"
        assert_sent_to c3, ":user1!sam@hector.irc NOTICE #test :hello"
      end
    end

    test :"messages can be sent between two sessions, one with an away message" do
      authenticated_connections do |c1, c2|
        c2.receive_line "AWAY bai"
        c1.receive_line "PRIVMSG user2 :hello world"
        c2.receive_line "AWAY"
        assert_sent_to c2, ":user1!sam@hector.irc PRIVMSG user2 :hello world"
        assert_sent_to c1, "301 user1 user2 :bai"
      end
    end
  end
end
