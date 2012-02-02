module Hector
  module Commands
    module Ping
      def on_ping
        respond_with(:pong, Hector.server_name, :source => Hector.server_name, :text => request.text)
      end
    end
  end
end
