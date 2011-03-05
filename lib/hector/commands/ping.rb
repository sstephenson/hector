# encoding: UTF-8

module Hector
  module Commands
    module Ping
      def on_ping
        respond_with(:pong, :source => Hector.server_name, :text => request.text)
      end
    end
  end
end
