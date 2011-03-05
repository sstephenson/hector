# encoding: UTF-8

module Hector
  class << self
    def defer(&block)
      EM.defer(&block)
    end

    def next_tick(&block)
      EM.next_tick(&block)
    end
  end
end
