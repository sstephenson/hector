require "digest/sha1"
require "eventmachine"

module Kernel
  def returning(value)
    yield value
    value
  end unless defined?(returning)
end

require "hector/errors"
require "hector/connection"
require "hector/identity"
require "hector/logging"
require "hector/request"
require "hector/response"
require "hector/session"

module Hector
  def self.start_server(address = "0.0.0.0", port = 6767)
    EventMachine.start_server(address, port, Connection)
    logger.info("Hector running on #{address}:#{port}")
  end
end
