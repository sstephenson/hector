module Hector
  class << self
    attr_accessor :server_name

    def start_server(options)
      address = options[:address] || "0.0.0.0"
      port = options[:port] || 6767
      ssl_port = options[:ssl_port] || 6868
      
      EventMachine.start_server(address, port, Connection)
      EventMachine.start_server(address, ssl_port, SSLConnection)
      logger.info("Hector running on #{address}:#{port}")
      logger.info("Secure Hector running on #{address}:#{ssl_port}")
    end
  end

  self.server_name = "hector.irc"
end
