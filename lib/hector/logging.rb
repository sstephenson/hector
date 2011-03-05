# encoding: UTF-8

module Hector
  class NullLogger
    def level=(l) end
    def debug(*)  end
    def info(*)   end
    def warn(*)   end
    def error(*)  end
    def fatal(*)  end
  end

  class << self
    attr_accessor :logger
  end

  self.logger = NullLogger.new
end
