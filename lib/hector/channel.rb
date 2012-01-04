module Hector
  class Channel
    attr_reader :name, :topic, :user_sessions, :created_at

    class << self
      def find(name)
        channels[normalize(name)]
      end

      def find_all_for_session(session)
        channels.values.find_all do |channel|
          channel.has_session?(session)
        end
      end

      def create(name)
        new(name).tap do |channel|
          channels[normalize(name)] = channel
        end
      end

      def find_or_create(name)
        find(name) || create(name)
      end

      def delete(name)
        channels.delete(name)
      end

      def normalize(name)
        name.force_encoding("UTF-8") if name.respond_to?(:force_encoding)
        if name =~ /^[#&+!][#&+!\-\w\p{L}\p{M}\p{N}\p{S}\p{P}\p{Co}]{1,49}$/u && name !~ /,/
          name.downcase
        else
          raise NoSuchChannel, name
        end
      end

      def reset!
        @channels = nil
      end

      protected
        def channels
          @channels ||= {}
        end
    end

    def initialize(name)
      @name = name
      @user_sessions = []
      @created_at = Time.now
    end

    def broadcast(command, *args)
      catch :stop do
        Session.broadcast_to(sessions, command, *args)
      end
    end

    def change_topic(session, topic)
      @topic = { :body => topic, :nickname => session.nickname, :time => Time.now }
    end

    def channel?
      true
    end

    def deliver(message_type, session, options)
      if has_session?(session)
        broadcast(message_type, name, options.merge(:except => session))
      else
        raise CannotSendToChannel, name
      end
    end

    def destroy
      self.class.delete(name)
    end

    def has_session?(session)
      sessions.include?(session)
    end

    def join(session)
      return if has_session?(session)
      user_sessions.push(session)
    end

    def nicknames
      user_sessions.map { |session| session.nickname }
    end

    def part(session)
      user_sessions.delete(session)
      destroy if user_sessions.empty?
    end

    def services
      Service.all
    end

    def sessions
      services + user_sessions
    end
  end
end
