# encoding: UTF-8

module Hector
  class Heartbeat
    def self.create_timer(interval)
      Object.new.tap do |o|
        def o.cancel; end
      end
    end
  end
end
