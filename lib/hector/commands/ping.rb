module Hector
  module Commands
    module Ping
      def on_ping
        respond_with(:pong, :source => "hector.irc", :text => request.text)
      end
    end
  end
end
