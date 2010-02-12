module Hector
  class Identity
    def self.authenticate(username, password)
      new(username)
    end

    def initialize(username)
      @username = username
    end
  end
end
