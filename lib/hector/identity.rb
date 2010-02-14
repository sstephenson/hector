module Hector
  class Identity
    class << self
      attr_accessor :filename

      def find(username)
        if password = identities[username]
          new(username, password)
        end
      end

      def authenticate(username, password)
        if identity = find(username)
          identity if identity.authenticate(password)
        end
      end

      def hash_password(password)
        Digest::SHA1.hexdigest(password)
      end

      def reset!
        @identities = nil
      end

      protected
        def identities
          @identities ||= YAML.load_file(filename) || {}
        rescue Exception => e
          @identities = {}
        end
    end

    def initialize(username, password)
      @username = username
      @password = password
    end

    def authenticate(password)
      self.class.hash_password(password) == @password
    end
  end
end
