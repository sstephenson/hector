module Hector
  class Session
    attr_reader :nickname, :connection, :identity

    class << self
      def nicknames
        sessions.keys
      end

      def find(nickname)
        sessions[normalize(nickname)]
      end

      def create(nickname, connection, identity)
        if find(nickname)
          raise NicknameInUse, nickname
        else
          new(nickname, connection, identity).tap do |session|
            sessions[normalize(nickname)] = session
          end
        end
      end

      def destroy(nickname)
        sessions.delete(normalize(nickname))
      end

      def normalize(nickname)
        if nickname =~ /^\w[\w-]{0,15}$/
          nickname.downcase
        else
          raise ErroneousNickname, nickname
        end
      end

      def reset!
        @sessions = nil
      end

      protected
        def sessions
          @sessions ||= {}
        end
    end

    def initialize(nickname, connection, identity)
      @nickname = nickname
      @connection = connection
      @identity = identity
    end

    def receive(request)
      @request = request
      if respond_to?(request.event_name)
        send(request.event_name)
      end
    ensure
      @request = nil
    end

    def welcome
      respond_with("001", nickname, :text => "Welcome to IRC")
      respond_with("422", :text => "MOTD File is missing")
    end

    def on_privmsg
      destination, text = request.args.first, request.text

      if channel?(destination)
        on_channel_privmsg(Channel.find(destination), text)
      else
        on_session_privmsg(Session.find(destination), text)
      end
    end

    def on_channel_privmsg(channel, text)
      if channel.has_session?(self)
        channel.broadcast(:privmsg, channel.channel_name, :source => source, :text => text, :except => self)
      else
        raise CannotSendToChannel, channel.channel_name
      end
    end

    def on_session_privmsg(session, text)
      if session
        session.respond_with(:privmsg, session.nickname, :source => source, :text => text)
      else
        raise NoSuchNickOrChannel, session.nickname
      end
    end

    def on_join
      Channel.find_or_create(request.args.first).join(self)
    end

    def on_names
      Channel.find(request.args.first).names(self)
    end

    def on_part
      Channel.find(request.args.first).part(self, request.text)
    end

    def on_topic
      channel = Channel.find(request.args.first).topic(self, request.text)
    end

    def on_quit
      connection.close_connection
    end

    def on_ping
      respond_with(:pong, 'hector');
    end

    def destroy
      self.class.destroy(nickname)
    end

    def respond_with(*args)
      connection.respond_with(*args)
    end

    def source
      "#{nickname}!#{identity.username}@hector"
    end

    protected
      attr_reader :request

      def channel?(destination)
        destination =~ /^#/
      end
  end
end
