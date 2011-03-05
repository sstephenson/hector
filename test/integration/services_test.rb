# encoding: UTF-8

require "test_helper"

module Hector
  class ServicesTest < IntegrationTest
    def setup
      super
      Hector::Session.register(Hector::TestService.new("TestService"))
    end

    test :"intercepting a channel message and delivering a replacement from the origin" do
      authenticated_connections(:join => "#test") do |c1, c2|
        c1.receive_line "PRIVMSG #test :!reverse foo bar"
        assert_not_sent_to c1, ":user1!sam@hector.irc PRIVMSG #test :rab oof"
        assert_not_sent_to c2, ":user1!sam@hector.irc PRIVMSG #test :!reverse foo bar"
        assert_sent_to c2, ":user1!sam@hector.irc PRIVMSG #test :rab oof"
      end
    end

    test :"intercepting a channel message and delivering a replacement from the service" do
      authenticated_connections(:join => "#test") do |c1, c2|
        c1.receive_line "PRIVMSG #test :!sum 2 3"
        assert_not_sent_to c2, ":user1!sam@hector.irc PRIVMSG #test :!sum 2 3"
        assert_sent_to c1, ":TestService!~TestService@hector.irc PRIVMSG #test :2 + 3 = 5"
        assert_sent_to c2, ":TestService!~TestService@hector.irc PRIVMSG #test :2 + 3 = 5"
      end
    end
  end
end
