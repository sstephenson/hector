module Hector
  module Commands
    module Part
      def on_part
        Channel.find(request.args.first).part(self, request.text)
      end
    end
  end
end
