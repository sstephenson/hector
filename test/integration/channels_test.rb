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
    
    test :"names command should be split into 512-byte responses" do
      authenticated_connections(:join => "#test") do |c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20, c21, c22, c23, c24, c25, c26, c27, c28, c29, c30, c31, c32, c33, c34, c35, c36, c37, c38, c39, c40, c41, c42, c43, c44, c45, c46, c47, c48, c49, c50, c51, c52, c53, c54, c55, c56, c57, c58, c59, c60, c61, c62, c63, c64, c65, c66, c67, c68, c69, c70|
        c1.receive_line "NAMES #test"
        assert_sent_to c1, ":hector.irc 353 user1 = #test :user1 user2 user3 user4 user5 user6 user7 user8 user9 user10 user11 user12 user13 user14 user15 user16 user17 user18 user19 user20 user21 user22 user23 user24 user25 user26 user27 user28 user29 user30 user31 user32 user33 user34 user35 user36 user37 user38 user39 user40 user41 user42 user43 user44 user45 user46 user47 user48 user49 user50 user51 user52 user53 user54 user55 user56 user57 user58 user59 user60 user61 user62 user63 user64 user65 user66 user67 user68 user69"
        assert_sent_to c1, ":hector.irc 353 user1 = #test :user70"
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
        assert_sent_to c2, "352 #test sam hector.irc hector.irc user1 H :0 Sam Stephenson"
        assert_sent_to c2, "352 #test sam hector.irc hector.irc user2 H :0 Sam Stephenson"
        assert_sent_to c2, "315 #test"
      end
    end
    
    test :"sending a WHO command to an active channel you've not yet joined should still list everyone" do
      authenticated_connections do |c1, c2, c3|
        c1.receive_line "JOIN #test"
        c2.receive_line "JOIN #test"
        c3.receive_line "WHO #test"
        assert_sent_to c3, "352 #test sam hector.irc hector.irc user1 H :0 Sam Stephenson"
        assert_sent_to c3, "352 #test sam hector.irc hector.irc user2 H :0 Sam Stephenson"
        assert_sent_to c3, "315 #test"
      end
    end

    test :"sending a WHO command about a real user should list their user data" do
      authenticated_connections do |c1, c2|
        c1.receive_line "WHO user2"
        assert_sent_to c1, "352 * sam hector.irc hector.irc user2 H :0 Sam Stephenson"
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

    test :"sending a WHOIS on a non-existent user should reply with a 401 then 318" do
      authenticated_connection.tap do |c|
        c.receive_line "WHOIS user2"
        assert_sent_to c, "401"
        assert_sent_to c, "318"
      end
    end

    test :"sending a WHOIS on a user not on any channels should list the following items and 318" do
      authenticated_connections do |c1, c2|
        c1.receive_line "WHOIS user2"
        assert_sent_to c1, "311"
        assert_sent_to c1, "312"
        assert_sent_to c1, "317"
        assert_sent_to c1, "318"
        assert_not_sent_to c1, "319" # no channels
      end
    end

    test :"sending a WHOIS on a user on channels should list the following items and 318" do
      authenticated_connections(:join => "#test") do |c1, c2|
        c1.receive_line "WHOIS user2"
        assert_sent_to c1, "311"
        assert_sent_to c1, "312"
        assert_sent_to c1, "319"
        assert_sent_to c1, "317"
        assert_sent_to c1, "318"
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

    test :"multiple channels can be joined with a single command" do
      authenticated_connection.tap do |c|
        c.receive_line "JOIN #channel1,#channel2,#channel3"
        assert_sent_to c, ":sam!sam@hector JOIN :#channel1"        
        assert_sent_to c, ":sam!sam@hector JOIN :#channel2"
        assert_sent_to c, ":sam!sam@hector JOIN :#channel3"
      end
    end
  end
end
