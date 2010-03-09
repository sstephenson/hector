module Hector
  class UserChannel < Channel
    class << self
      def create(name)
        register(new(name))
      end

      def find_or_create(name)
        find(name) || create(name)
      end
    end

    def part(session)
      super
      destroy if sessions.empty?
    end
  end
end
