module Hector
  class Identity
    attr_accessor :username

    class << self
      attr_accessor :adapter

      def authenticate(username, password)
        if adapter.authenticate(username, password)
          new(username)
        else
          raise InvalidPassword
        end
      end
    end

    def initialize(username)
      @username = username
    end

    def ==(identity)
      Identity.adapter.normalize(username) == Identity.adapter.normalize(identity.username)
    end
  end
end
