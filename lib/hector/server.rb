module Hector
  class << self
    attr_accessor :server_name, :address, :port, :ssl_port

    def start_server
      EventMachine.start_server(@address, @port, Connection)
      EventMachine.start_server(@address, @ssl_port, SSLConnection)
      logger.info("Hector running on #{@address}:#{@port}")
      logger.info("Secure Hector running on #{@address}:#{@ssl_port}")
    end
  end

  self.server_name = "hector.irc"
  self.address = "0.0.0.0"
  self.port = 6767
  self.ssl_port = 6868
end
