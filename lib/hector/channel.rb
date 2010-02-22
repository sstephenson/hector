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

    def has_session?(session)
      sessions.include?(session)
    end

    def nicknames
      sessions.map { |session| session.nickname }
    end

    def change_topic(session, topic)
      @topic = {:body => topic, :nickname => session.nickname, :time => Time.new.to_i}
      broadcast(:topic, name, :source => session.source, :text => topic)
    end

    def respond_to_topic(session)
      if @topic
        session.respond_with(332, session.nickname, name, :source => "hector.irc", :text => topic[:body])
        session.respond_with(333, session.nickname, name, topic[:nickname], topic[:time], :source => "hector.irc")
      else
        session.respond_with(331, session.nickname, name, :source => "hector.irc", :text => "No topic is set.")
      end
    end

    def respond_to_names(session)
      session.respond_with(353, session.nickname, "=", name, :source => "hector.irc", :text => nicknames.join(" "))
      session.respond_with(366, session.nickname, name, :source => "hector.irc", :text => "End of /NAMES list.");
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
      remove(session)
    end

    def remove(session)
      sessions.delete(session)
      cleanup
    end

    def broadcast(command, *args)
      Session.broadcast_to(sessions, command, *args)
    end

    def destroy
      self.class.delete(name)
    end

    protected
      def cleanup
        destroy unless sessions.any?
      end
  end
end
