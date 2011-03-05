module Hector
  module Concerns
    module KeepAlive
      def initialize_keep_alive
        @received_pong = true
        @heartbeat = Hector::Heartbeat.new { on_heartbeat }
      end

      def on_heartbeat
        if @received_pong
          @received_pong = false
          respond_with(:ping, Hector.server_name)
        else
          @quit_message = "Ping timeout"
          connection.close_connection(true)
        end
      end

      def destroy_keep_alive
        @heartbeat.stop
      end
    end
  end
end
