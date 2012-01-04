module Hector
  class IntegrationTest < TestCase
    def setup
      reset!
    end

    def teardown
      reset!
    end

    def reset!
      Session.reset!
      Channel.reset!
    end

    def authenticated_connection(nickname = "sam")
      connection.tap do |c|
        authenticate! c, nickname
      end
    end

    def authenticated_connections(options = {}, &block)
      nickname = options[:nickname] || "user"
      connections = Array.new(block.arity) do |i|
        authenticated_connection("#{nickname}#{i+1}").tap do |c|
          if options[:join]
            Array(options[:join]).each do |channel|
              c.receive_line("JOIN #{channel}")
            end
          end
        end
      end

      yield *connections
    end

    def authenticate!(connection, nickname)
      pass! connection
      user! connection
      nick! connection, nickname
    end

    def pass!(connection, password = "secret")
      connection.receive_line("PASS #{password}")
    end

    def user!(connection, username = "sam", realname = "Sam Stephenson")
      connection.receive_line("USER #{username} * 0 :#{realname}")
    end

    def nick!(connection, nickname = "sam")
      connection.receive_line("NICK #{nickname}")
    end

    def connection_nickname(connection)
      connection.instance_variable_get(:@nickname)
    end

    def capture_sent_data(connection)
      length = connection.sent_data.length
      yield
      connection.sent_data[length..-1]
    end

    def assert_sent_to(connection, line, &block)
      sent_data = block ? capture_sent_data(connection, &block) : connection.sent_data
      assert sent_data =~ /^#{line.is_a?(Regexp) ? line : Regexp.escape(line)}/, explain_sent_to(line, sent_data)
    end
    
    def explain_sent_to(line, sent_data)
      [].tap do |lines|
        lines.push("Expected to receive #{line.inspect}, but did not receive it:")
        lines.concat(sent_data.split(/[\r\n]+/).map { |line| line.inspect })
      end.join("\n")
    end

    def assert_not_sent_to(connection, line, &block)
      sent_data = block ? capture_sent_data(connection, &block) : connection.sent_data
      assert sent_data !~ /^#{line.is_a?(Regexp) ? line : Regexp.escape(line)}/, explain_not_sent_to(line, sent_data)
    end
    
    def explain_not_sent_to(line, sent_data)
      sent_data = sent_data.split(/[\r\n]+/).map do |sent_line|
        sent_line !~ /^#{line.is_a?(Regexp) ? line : Regexp.escape(line)}/ ? "  #{sent_line.inspect}" : "* #{sent_line.inspect}"
      end
      line_number = sent_data.index { |line| line[0, 2] == "* " }
      
      [].tap do |lines|
        lines.push("Expected not to receive #{line.inspect}, but received it on line #{line_number}:")
        lines.concat(sent_data)
      end.join("\n")
    end

    def assert_nothing_sent_to(connection, &block)
      assert_equal "", capture_sent_data(connection, &block)
    end

    def assert_welcomed(connection)
      assert_sent_to connection, ":hector.irc 001 #{connection_nickname(connection)} :"
      assert_sent_to connection, ":hector.irc 422 :"
    end

    def assert_no_such_nick_or_channel(connection, nickname)
      assert_sent_to connection, ":hector.irc 401 #{nickname} :"
    end

    def assert_no_such_channel(connection, channel)
      assert_sent_to connection, ":hector.irc 403 #{channel} :"
    end

    def assert_cannot_send_to_channel(connection, channel)
      assert_sent_to connection, ":hector.irc 404 #{channel} :"
    end

    def assert_erroneous_nickname(connection, nickname = connection_nickname(connection))
      assert_sent_to connection, ":hector.irc 432 #{nickname} :"
    end

    def assert_nickname_in_use(connection, nickname = connection_nickname(connection))
      assert_sent_to connection, ":hector.irc 433 * #{nickname} :"
    end

    def assert_invalid_password(connection)
      assert_sent_to connection, ":hector.irc 464 :"
    end

    def assert_closed(connection)
      assert connection.connection_closed?
    end

    def assert_not_closed(connection)
      assert !connection.connection_closed?
    end
  end
end
