module Hector
  module Commands
    module Topic
      def on_topic
        channel = Channel.find(request.args.first)

        if request.args.length > 1
          channel.change_topic(self, request.text)
        else
          channel.respond_to_topic(self)
        end
      end
    end
  end
end
