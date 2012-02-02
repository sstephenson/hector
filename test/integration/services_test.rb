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
    
    test :"WHO responses should not include services" do
      authenticated_connections(:join => "#test") do |c1, c2|
        c2.receive_line "WHO #test"
        assert_sent_to c2, ":hector.irc 352 user2 #test sam hector.irc hector.irc user1 H :0 Sam Stephenson"
        assert_sent_to c2, ":hector.irc 352 user2 #test sam hector.irc hector.irc user2 H :0 Sam Stephenson"
        assert_sent_to c2, ":hector.irc 315 user2 #test"
      end
    end
  end
end
