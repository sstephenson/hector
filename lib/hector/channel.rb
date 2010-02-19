module Hector
  class Channel
    attr_reader :channel_name, :channel_topic, :sessions

    class << self
      def channel_names
        channels.keys
      end

      def find(channel_name)
        channels[normalize(channel_name)]
      end

      def find_all_for_session(session)
        channels.values.find_all do |channel|
          channel.has_session?(session)
        end
      end

      def create(channel_name)
        new(channel_name).tap do |channel|
          channels[normalize(channel_name)] = channel
        end
      end

      def find_or_create(channel_name)
        find(channel_name) || create(channel_name)
      end

      def destroy(channel_name)
        channels.delete(channel_name)
      end

      def normalize(channel_name)
        if channel_name =~ /^#\w[\w-]{0,15}$/
          channel_name.downcase
        else
          raise NoSuchChannel, channel_name
        end
      end

      protected
        def channels
          @channels ||= {}
        end
    end

    def initialize(channel_name)
      @channel_name = channel_name
      @channel_topic = channel_topic
      @sessions = []
    end

    def has_session?(session)
      sessions.include?(session)
    end

    def topic(session, topic)
      @channel_topic = topic
      broadcast(:topic, channel_name, :source => session.source, :text => channel_topic)
    end

    def names(session)
      session.respond_with(353, session.nickname, '=', channel_name, :text => sessions.map { |session| session.nickname }.join(" "))
      session.respond_with(366, session.nickname, channel_name, :text => "End of /NAMES list.");
    end

    def join(session)
      return if sessions.include?(session)
      sessions.push(session)
      broadcast(:join, :source => session.source, :text => channel_name)
      session.respond_with(332, session.nickname, channel_name, :text => channel_topic)
      names(session)
    end

    def part(session, message)
      return unless sessions.include?(session)
      broadcast(:part, channel_name, :source => session.source, :text => message)
      sessions.delete(session)
    end

    def broadcast(command, *args)
      except = args.last.delete(:except) if args.last.is_a?(Hash)
      sessions.each do |session|
        session.respond_with(command, *args) unless session == except
      end
    end
  end
end
