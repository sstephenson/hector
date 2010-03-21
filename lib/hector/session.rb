module Hector
  class Session
    include Concerns::KeepAlive
    include Concerns::Presence

    include Commands::Join
    include Commands::Names
    include Commands::Nick
    include Commands::Notice
    include Commands::Part
    include Commands::Ping
    include Commands::Pong
    include Commands::Privmsg
    include Commands::Quit
    include Commands::Topic
    include Commands::Who
    include Commands::Whois

    attr_reader :nickname, :connection, :identity, :realname, :request

    class << self
      def nicknames
        sessions.keys
      end

      def find(nickname)
        sessions[normalize(nickname)]
      end

      def create(nickname, connection, identity, realname)
        if find(nickname)
          raise NicknameInUse, nickname
        else
          new(nickname, connection, identity, realname).tap do |session|
            sessions[normalize(nickname)] = session
          end
        end
      end

      def rename(from, to)
        if find(to)
          raise NicknameInUse, to
        else
          find(from).tap do |session|
            delete(from)
            sessions[normalize(to)] = session
          end
        end
      end

      def delete(nickname)
        sessions.delete(normalize(nickname))
      end

      def broadcast_to(sessions, command, *args)
        except = args.last.delete(:except) if args.last.is_a?(Hash)
        sessions.each do |session|
          session.respond_with(command, *args) unless session == except
        end
      end

      def normalize(nickname)
        if nickname =~ /^\w[\w-]{0,15}$/u
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

    def initialize(nickname, connection, identity, realname)
      @nickname   = nickname
      @connection = connection
      @identity   = identity
      @realname   = realname
      initialize_keep_alive
      initialize_presence
    end

    def broadcast(command, *args)
      Session.broadcast_to(peer_sessions, command, *args)
    end

    def deliver(message_type, session, options)
      respond_with(message_type, nickname, options)
    end

    def destroy
      destroy_presence
      destroy_keep_alive
      self.class.delete(nickname)
    end

    def find(name)
      destination_klass_for(name).find(name).tap do |destination|
        raise NoSuchNickOrChannel, name unless destination
      end
    end

    def hostname
      Hector.server_name
    end

    def name
      nickname
    end

    def receive(request)
      @request = request
      if respond_to?(request.event_name)
        send(request.event_name)
      end
    ensure
      @request = nil
    end

    def rename(new_nickname)
      Session.rename(nickname, new_nickname)
      @nickname = new_nickname
    end

    def respond_with(*args)
      connection.respond_with(*args)
    end

    def source
      "#{nickname}!#{username}@#{hostname}"
    end

    def username
      identity.username
    end

    protected
      def destination_klass_for(name)
        name =~ /^#/ ? Channel : Session
      end
  end
end
