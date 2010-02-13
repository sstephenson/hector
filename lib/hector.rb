begin
  require "eventmachine"
rescue LoadError
  retry if require "rubygems"
end

require "hector/connection"
require "hector/identity"
require "hector/request"
require "hector/session"

module Kernel
  def returning(value)
    yield value
    value
  end unless defined?(returning)
end

module Hector
  def self.start_server(address = "0.0.0.0", port = 6767)
    EventMachine.start_server(address, port, Connection)
    puts "Hector running on #{address}:#{port}"
  end
end
