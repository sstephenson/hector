module Hector
  class Channel
    attr_reader :name, :topic, :sessions

    class << self
      def find(name)
        channels[normalize(name)]
      end

      def create(name)
        new(name).tap do |channel|
          channels[normalize(name)] = channel
        end
      end

      def find_or_create(name)
        find(name) || create(name)
      end

      def destroy(name)
        channels.delete(name)
      end

      def normalize(name)
        if name =~ /^#\w[\w-]{0,15}$/
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

    def has_session?(session)
      sessions.include?(session)
    end

    def nicknames
      sessions.map { |session| session.nickname }
    end

    def change_topic(session, topic)
      @topic = topic
      broadcast(:topic, name, :source => session.source, :text => topic)
    end

    def respond_to_topic(session)
      if @topic
        session.respond_with(332, session.nickname, name, :source => "hector.irc", :text => topic)
      else
        session.respond_with(331, session.nickname, name, :source => "hector.irc", :text => "No topic is set.")
      end
    end

    def respond_to_names(session)
      session.respond_with(353, session.nickname, "=", name, :source => "hector.irc", :text => nicknames.join(" "))
      session.respond_with(366, session.nickname, name, :source => "hector.irc", :text => "End of /NAMES list.");
    end

    def respond_to_who(session)
      sessions.each do |user_session|
        session.respond_with(352, name, user_session.identity.username, "hector.irc", "hector.irc", user_session.nickname, "H 0", user_session.realname)
      end
      session.respond_with(315, name, "End of /WHO list.")
    end

    def join(session)
      return if sessions.include?(session)
      sessions.push(session)
      broadcast(:join, :source => session.source, :text => name)
      respond_to_topic(session)
      respond_to_names(session)
    end

    def part(session, message)
      return unless sessions.include?(session)
      broadcast(:part, name, :source => session.source, :text => message)
      sessions.delete(session)
      cleanup
    end

    def broadcast(command, *args)
      except = args.last.delete(:except) if args.last.is_a?(Hash)
      sessions.each do |session|
        session.respond_with(command, *args) unless session == except
      end
    end

    def destroy
      self.class.destroy(name)
    end

    protected
      def cleanup
        destroy unless sessions.any?
      end
  end
end
