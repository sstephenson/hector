begin
  require "eventmachine"
rescue LoadError
  retry if require "rubygems"
end

require "hector/connection"
require "hector/identity"
require "hector/request"
require "hector/session"

module Hector
  def self.start_server(address = "0.0.0.0", port = 6767)
    EventMachine.start_server(address, port, Connection)
  end
end
