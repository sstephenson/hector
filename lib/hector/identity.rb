module Hector
  class Identity
    attr_accessor :username

    class << self
      attr_accessor :filename

      def find(username)
        if password = identities[username]
          new(username, password)
        end
      end

      def authenticate(username, password)
        identity = find(username)
        if identity && identity.authenticate(password)
          identity
        else
          raise InvalidPassword
        end
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
      self.hash_password(password) == @password
    end
    
    def hash_password(password)
      Digest::SHA1.hexdigest(Digest::SHA1.hexdigest(@username) + password)
    end
  end
end
