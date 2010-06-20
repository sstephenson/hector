module Hector
  class << self
    def defer(&block)
      EM.defer(&block)
    end
  end
end
