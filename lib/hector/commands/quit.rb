module Hector
  module Commands
    module Quit
      def on_quit
        @quit_message = "Quit: #{request.text}"
        connection.close_connection(true)
      end
    end
  end
end
