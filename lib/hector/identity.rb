module Hector
  class Identity
    def self.authenticate(username, password)
      new(username) if password == "secret"
    end

    def initialize(username)
      @username = username
    end
  end
end
