module Hector
  class Session
    attr_reader :connection, :identity, :nickname

    def initialize(connection, identity, nickname)
      @connection = connection
      @identity = identity
      @nickname = nickname
      respond_with("001", nickname, :text => "Welcome to IRC")
    end

    def receive(request)
      if respond_to?(request.event_name)
        send(request.event_name)
      else
        connection.close_connection
      end
    end

    def unbind
    end

    def request
      connection.request
    end

    def respond_with(*args)
      connection.respond_with(*args)
    end
  end
end
