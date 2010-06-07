module Hector
  class << self
    def deferred_blocks
      @deferred_blocks ||= []
    end

    def defer(&block)
      deferred_blocks.push(block)
    end

    def process_deferred_blocks
      until deferred_blocks.empty?
        deferred_blocks.shift.call
      end
    end
  end
end
