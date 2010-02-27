module Hector
  class Channel
    attr_reader :name, :topic, :sessions

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
        if name =~ /^#\w[\w-]{0,15}$/u
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
      @sessions = []
    end

    def broadcast(command, *args)
      Session.broadcast_to(sessions, command, *args)
    end

    def change_topic(session, topic)
      @topic = { :body => topic, :nickname => session.nickname, :time => Time.now }
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
      destroy if sessions.empty?
    end
  end
end
