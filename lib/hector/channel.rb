module Hector
  class Channel
    attr_reader :name, :topic, :sessions

    CHANNELS = {}

    class << self
      def find(name)
        channels[normalize(name)]
      end

      def find_all_for_session(session)
        channels.values.find_all do |channel|
          channel.has_session?(session)
        end
      end

      def delete(name)
        channels.delete(name)
      end

      def normalize(name)
        if name =~ /^#\w[\w-]{0,15}$/u
          name.downcase
        else
          raise NoSuchChannel, name
        end
      end

      def register(channel)
        channels[normalize(channel.name)] = channel
        channel
      end

      def reset!
        channels.clear
      end

      protected
        def channels
          CHANNELS
        end
    end

    def initialize(name)
      @name = name
      @sessions = []
    end

    def broadcast(command, *args)
      Session.broadcast_to(sessions, command, *args)
    end

    def change_topic(session, topic)
      @topic = { :body => topic, :nickname => session.nickname, :time => Time.now }
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
      return if sessions.include?(session)
      sessions.push(session)
    end

    def nicknames
      sessions.map { |session| session.nickname }
    end

    def part(session)
      sessions.delete(session)
    end
  end
end
