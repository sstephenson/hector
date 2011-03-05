# encoding: UTF-8

module Hector
  class Heartbeat
    def self.create_timer(interval, &block)
      EventMachine::PeriodicTimer.new(interval, &block)
    end

    def initialize(interval = 60, &block)
      @interval, @block = interval, block
      start
    end

    def start
      @timer ||= self.class.create_timer(@interval) { pulse }
    end

    def pulse
      @block.call
    end

    def stop
      @timer.cancel
      @timer = nil
    end
  end
end
