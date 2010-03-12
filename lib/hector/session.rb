module Hector
  class Session
    include Concerns::KeepAlive
    include Concerns::Presence

    include Commands::Join
    include Commands::Mode
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

    attr_reader :nickname, :request, :response

    SESSIONS = {}

    class << self
      def nicknames
        sessions.keys
      end

      def find(nickname)
        sessions[normalize(nickname)]
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

      def register(session)
        sessions[normalize(session.nickname)] = session
        session
      end

      def reset!
        sessions.clear
      end

      protected
        def sessions
          SESSIONS
        end
    end

    def initialize(nickname)
      @nickname = nickname
    end

    def broadcast(command, *args)
      Session.broadcast_to(peer_sessions, command, *args)
    end

    def channel?
      false
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

    def hostname
      Hector.server_name
    end

    def realname
      nickname
    end

    def receive(request)
      @request = request
      if respond_to?(@request.event_name)
        send(@request.event_name)
      end
    ensure
      @request = nil
    end

    def rename(new_nickname)
      Session.rename(nickname, new_nickname)
      @nickname = new_nickname
    end

    def respond_with(command, *args)
      @response = command.is_a?(Response) ? command : Response.new(command, *args)
      if respond_to?(@response.event_name)
        send(@response.event_name)
      end
      @response
    ensure
      @response = nil
    end

    def source
      "#{nickname}!#{username}@#{hostname}"
    end

    def username
      "~#{nickname}"
    end

    protected
      def destination_klass_for(name)
        name =~ /^#/ ? Channel : Session
      end
  end
end
