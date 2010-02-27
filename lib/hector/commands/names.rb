module Hector
  module Commands
    module Names
      def on_names
        Channel.find(request.args.first).respond_to_names(self)
      end
    end
  end
end
