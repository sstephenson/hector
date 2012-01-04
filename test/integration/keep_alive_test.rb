require "test_helper"

module Hector
  class KeepAliveTest < IntegrationTest
    test :"keep-alive ping is sent on pulse" do
      authenticated_connection.tap do |c|
        assert_not_sent_to c, ":hector.irc PING hector.irc"
        assert_sent_to c, ":hector.irc PING hector.irc" do
          pulse(c)
        end
        assert !c.connection_closed?
      end
    end

    test :"responding with pong results in another ping on the next pulse" do
      authenticated_connection.tap do |c|
        pulse(c)
        c.receive_line "PONG hector.irc"
        assert_sent_to c, ":hector.irc PING hector.irc" do
          pulse(c)
        end
        assert !c.connection_closed?
      end
    end

    test :"not responding with pong results in disconnection on the next pulse" do
      authenticated_connection.tap do |c|
        pulse(c)
        assert_not_sent_to c, ":hector.irc PING hector.irc" do
          pulse(c)
        end
        assert c.connection_closed?
      end
    end

    test :"channel members are notified of keep-alive timeouts" do
      authenticated_connections(:join => "#test") do |c1, c2|
        pulse(c1)
        assert_sent_to c2, ":user1!sam@hector.irc QUIT" do
          pulse(c1)
        end
      end
    end

    def pulse(connection)
      heartbeat(connection).pulse
    end

    def heartbeat(connection)
      connection.session.instance_variable_get(:@heartbeat)
    end
  end
end
