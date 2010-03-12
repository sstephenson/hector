module Hector
  class UserSession < Session
    attr_reader :connection, :identity, :realname

    class << self
      def create(nickname, connection, identity, realname)
        if find(nickname)
          raise NicknameInUse, nickname
        else
          register UserSession.new(nickname, connection, identity, realname)
        end
      end
    end

    def initialize(nickname, connection, identity, realname)
      super(nickname)
      @connection = connection
      @identity   = identity
      @realname   = realname
      initialize_keep_alive
      initialize_presence
    end

    def destroy
      super
      destroy_presence
      destroy_keep_alive
    end

    def respond_with(*)
      connection.respond_with(super)
    end

    def username
      identity.username
    end
  end
end
