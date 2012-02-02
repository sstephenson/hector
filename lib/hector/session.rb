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
    include Commands::Realname
    include Commands::Topic
    include Commands::Who
    include Commands::Whois
    include Commands::Away
    include Commands::Invite

    attr_reader :nickname, :request, :response, :away_message

    SESSIONS = {}

    class << self
      def all
        sessions.values.grep(self)
      end

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
        nickname.force_encoding("UTF-8") if nickname.respond_to?(:force_encoding)
        if nickname =~ /^[\p{L}\p{M}\p{N}\p{So}\p{Co}\w][\p{L}\p{M}\p{N}\p{So}\p{Co}\p{P}\w\|\-]{0,15}$/u
          nickname.downcase
        else
          raise ErroneousNickname, nickname
        end
      end

      def register(session)
        yield session if block_given?
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
      @response = command.is_a?(Response) ? command : Response.new(command, *preprocess_args(args))
      if respond_to?(@response.event_name)
        send(@response.event_name)
      end
      @response
    ensure
      @response = nil
    end

    def away(away_message)
      @away_message = away_message
    end

    def away?
      !@away_message.nil?
    end

    def back
      @away_message = nil
    end

    def source
      "#{nickname}!#{username}@#{hostname}"
    end

    def username
      "~#{nickname}"
    end

    def who
      "#{identity.username} #{Hector.server_name} #{Hector.server_name} #{nickname} H :0 #{realname}"
    end

    protected
      def destination_klass_for(name)
        name =~ /^#/ ? Channel : Session
      end

      def preprocess_args(args)
        args.map do |arg|
          if arg.is_a?(Symbol) && arg.to_s[0, 1] == "$"
            send(arg.to_s[1..-1])
          else
            arg
          end
        end
      end
  end
end
