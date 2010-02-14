module Hector
  class Session
    attr_reader :connection, :identity, :nickname

    class << self
      def sessions
        @sessions ||= []
      end

      def create(connection, identity, nickname)
        returning new(connection, identity, nickname) do |session|
          sessions.push(session)
        end
      end

      def destroy(session)
        sessions.delete(session)
      end

      def reset!
        @sessions = nil
      end
    end

    def initialize(connection, identity, nickname)
      @connection = connection
      @identity = identity
      @nickname = nickname
    end

    def welcome
      respond_with("001", nickname, :text => "Welcome to IRC")
    end

    def receive(request)
      @request = request
      if respond_to?(request.event_name)
        send(request.event_name)
      end
    ensure
      @request = nil
    end

    def on_quit
      connection.close_connection
    end

    def destroy
      self.class.destroy(self)
    end

    protected
      attr_reader :request

      def respond_with(*args)
        connection.respond_with(*args)
      end
  end
end
