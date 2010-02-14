require "test_helper"

module Hector
  class MessagingTest < IntegrationTest
    test :"private messages can be sent between two sessions" do
      c1 = authenticated_connection("sam")
      c2 = authenticated_connection("clint")

      c1.receive_line "PRIVMSG clint :hi clint"
      assert_sent_to c2, ":sam!sam@hector PRIVMSG clint :hi clint"
    end

    test :"sending a message to a nonexistent session should result in a 401" do
      authenticated_connection.tap do |c|
        c.receive_line "PRIVMSG clint :hi clint"
        assert_no_such_nick_or_channel c, "clint"
      end
    end
  end
end
