require "digest/sha1"
require "eventmachine"
require "socket"

require "hector/errors"
require "hector/connection"
require "hector/identity"
require "hector/logging"
require "hector/request"
require "hector/response"
require "hector/session"

module Hector
  def self.start_server(address = "0.0.0.0", port = 6767, ssl_port = 6868)
    EventMachine.start_server(address, port, Connection)
    EventMachine.start_server(address, ssl_port, SSLConnection)
    logger.info("Hector running on #{address}:#{port}")
    logger.info("Secure Hector running on #{address}:#{ssl_port}")
  end
end
