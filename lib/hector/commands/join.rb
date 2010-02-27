module Hector
  module Commands
    module Join
      def on_join
        request.args.first.split(",").each do |channel|
          Channel.find_or_create(channel).join(self)
        end
      end
    end
  end
end
