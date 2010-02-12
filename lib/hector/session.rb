module Hector
  class Session
    attr_reader :connection, :identity

    def initialize(connection, identity)
      @connection = connection
      @identity = identity
    end

    def receive(request)
    end

    def unbind
    end
  end
end
