require "test_helper"

module Hector
  class ChannelsTest < IntegrationTest
    test :"channels can be joined" do
      authenticated_connections do |c1, c2|
        c1.receive_line "JOIN #test"
        assert_sent_to c1, ":user1!sam@hector JOIN :#test"

        c2.receive_line "JOIN #test"
        assert_sent_to c1, ":user2!sam@hector JOIN :#test"
        assert_sent_to c2, ":user2!sam@hector JOIN :#test"
      end
    end

    test :"joining a channel twice does nothing" do
      authenticated_connection.tap do |c|
        c.receive_line "JOIN #test"
        assert_nothing_sent_to(c) do
          c.receive_line "JOIN #test"
        end
      end
    end

    test :"joining an invalid channel name responds with a 403" do
      authenticated_connection.tap do |c|
        c.receive_line "JOIN #8*(&x"
        assert_no_such_channel c, "#8*(&x"
      end
    end

    test :"joining a channel should send session nicknames" do
      authenticated_connections(:join => "#test") do |c1, c2, c3|
        assert_sent_to c1, ":hector.irc 353 user1 = #test :user1"
        assert_sent_to c2, ":hector.irc 353 user2 = #test :user1 user2"
        assert_sent_to c3, ":hector.irc 353 user3 = #test :user1 user2 user3"
      end
    end

    test :"channels can be parted" do
      authenticated_connections(:join => "#test") do |c1, c2|
        c1.receive_line "PART #test :lämnar"
        assert_sent_to c1, ":user1!sam@hector PART #test :lämnar"
        assert_sent_to c2, ":user1!sam@hector PART #test :lämnar"
      end
    end

    test :"parting a channel should remove the session from the channel" do
      authenticated_connections(:join => "#test") do |c1, c2|
        c1.receive_line "PART #test"
        sent_data = capture_sent_data(c2) { c2.receive_line "NAMES #test" }
        assert sent_data !~ /user1/
      end
    end

    test :"quitting should notify all the session's peers" do
      authenticated_connections(:join => "#test") do |c1, c2, c3|
        c1.receive_line "QUIT :outta here"
        assert_not_sent_to c1, ":user1!sam@hector QUIT :Quit: outta here"
        assert_sent_to c2, ":user1!sam@hector QUIT :Quit: outta here"
        assert_sent_to c3, ":user1!sam@hector QUIT :Quit: outta here"
      end
    end

    test :"quitting should notify peers only once" do
      authenticated_connections(:join => ["#test1", "#test2"]) do |c1, c2|
        sent_data = capture_sent_data(c2) { c1.receive_line "QUIT :outta here" }
        assert_equal ":user1!sam@hector QUIT :Quit: outta here\r\n", sent_data
      end
    end

    test :"quitting should remove the session from its channels" do
      authenticated_connections(:join => ["#test1", "#test2"]) do |c1, c2|
        c1.receive_line "QUIT :bye"
        sent_data = capture_sent_data(c2) do
          c2.receive_line "NAMES #test1"
          c2.receive_line "NAMES #test2"
        end
        assert sent_data !~ /user1/
      end
    end

    test :"disconnecting without quitting should notify peers" do
      authenticated_connections(:join => "#test") do |c1, c2|
        c1.close_connection
        assert_sent_to c2, ":user1!sam@hector QUIT :Connection closed"
      end
    end

    test :"disconnecting should remove the session from its channels" do
      authenticated_connections(:join => ["#test1", "#test2"]) do |c1, c2|
        c1.close_connection
        sent_data = capture_sent_data(c2) do
          c2.receive_line "NAMES #test1"
          c2.receive_line "NAMES #test2"
        end
        assert sent_data !~ /user1/
      end
    end

    test :"names command should send session nicknames" do
      authenticated_connections(:join => "#test") do |c1, c2, c3|
        c1.receive_line "NAMES #test"
        assert_sent_to c1, ":hector.irc 353 user1 = #test :user1 user2 user3"
        assert_sent_to c1, ":hector.irc 366 user1 #test :"
      end
    end

    test :"topic command with text should set the channel topic" do
      authenticated_connections(:join => "#test") do |c1, c2|
        c1.receive_line "TOPIC #test :this is my topic"
        assert_sent_to c1, ":user1!sam@hector TOPIC #test :this is my topic"
        assert_sent_to c2, ":user1!sam@hector TOPIC #test :this is my topic"
      end
    end

    test :"topic command with no arguments should send the channel topic" do
      authenticated_connection.tap do |c|
        c.receive_line "JOIN #test"
        c.receive_line "TOPIC #test :hello world"
        assert_sent_to c, ":hector.irc 332 sam #test :hello world" do
          c.receive_line "TOPIC #test"
        end
      end
    end

    test :"topic command sends timestamp and nickname" do
      authenticated_connection.tap do |c|
        c.receive_line "JOIN #test"
        c.receive_line "TOPIC #test :hello world"
        assert_sent_to c, /:hector\.irc 333 sam #test sam \d+/ do
          c.receive_line "TOPIC #test"
        end
      end
    end

    test :"topic command with no arguments should send 331 when no topic is set" do
      authenticated_connection.tap do |c|
        c.receive_line "JOIN #test"
        assert_sent_to c, ":hector.irc 331 sam #test :" do
          c.receive_line "TOPIC #test"
        end
      end
    end

    test :"channel topics are erased when the last session parts" do
      authenticated_connection("sam").tap do |c|
        c.receive_line "JOIN #test"
        c.receive_line "TOPIC #test :hello world"
        c.receive_line "PART #test"
      end

      authenticated_connection("clint").tap do |c|
        c.receive_line "JOIN #test"
        assert_not_sent_to c, ":hector.irc 332 clint #test :hello world"
      end
    end

    test :"channel topics are erased when the last session quits" do
      authenticated_connection("sam").tap do |c|
        c.receive_line "JOIN #test"
        c.receive_line "TOPIC #test :hello world"
        c.receive_line "QUIT"
      end

      authenticated_connection("clint").tap do |c|
        c.receive_line "JOIN #test"
        assert_not_sent_to c, ":hector.irc 332 clint #test :hello world"
      end
    end

    test :"sending a WHO command to an empty or undefined channel should produce an end of list message" do
      authenticated_connection.tap do |c|
        c.receive_line "WHO #test"
        assert_sent_to c, "315 #test"
        assert_not_sent_to c, "352"
      end
    end

    test :"sending a WHO command to a channel you have joined should list each occupant's info" do
      authenticated_connections(:join => "#test") do |c1, c2|
        c2.receive_line "WHO #test"
        assert_sent_to c2, "352 #test sam hector.irc hector.irc user1 H 0 Sam Stephenson"
        assert_sent_to c2, "352 #test sam hector.irc hector.irc user2 H 0 Sam Stephenson"
        assert_sent_to c2, "315 #test"
      end
    end
    
    test :"sending a WHO command to an active channel you've not yet joined should still list everyone" do
      authenticated_connections do |c1, c2, c3|
        c1.receive_line "JOIN #test"
        c2.receive_line "JOIN #test"
        c3.receive_line "WHO #test"
        assert_sent_to c3, "352 #test sam hector.irc hector.irc user1 H 0 Sam Stephenson"
        assert_sent_to c3, "352 #test sam hector.irc hector.irc user2 H 0 Sam Stephenson"
        assert_sent_to c3, "315 #test"
      end
    end

    test :"sending a WHO command about a real user should list their user data" do
      authenticated_connections do |c1, c2|
        c1.receive_line "WHO user2"
        assert_sent_to c1, "352 * sam hector.irc hector.irc user2 H 0 Sam Stephenson"
        assert_sent_to c1, "315 user2"
      end
    end

    test :"sending a WHO command about a non-existent user should produce an end of list message" do
      authenticated_connection.tap do |c|
        c.receive_line "WHO user2"
        assert_sent_to c, "315 user2"
        assert_not_sent_to c, "352"
      end
    end

    test :"changing nicknames should notify peers" do
      authenticated_connections(:join => "#test") do |c1, c2, c3, c4|
        c4.receive_line "PART #test"
        c1.receive_line "NICK sam"

        assert_sent_to c1, ":user1 NICK sam"
        assert_sent_to c2, ":user1 NICK sam"
        assert_sent_to c3, ":user1 NICK sam"
        assert_not_sent_to c4, ":user1 NICK sam"
      end
    end
  end
end
