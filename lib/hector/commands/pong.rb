module Hector
  module Commands
    module Pong
      def on_pong
        @received_pong = true
      end
    end
  end
end
