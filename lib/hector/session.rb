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

      if session = Session.find(destination)
        session.respond_with("PRIVMSG", destination, :source => source, :text => text)
      else
        raise NoSuchNickOrChannel, destination
      end
    end

    def on_quit
      connection.close_connection
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
  end
end
