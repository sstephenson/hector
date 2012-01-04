module Hector
  module Commands
    module Join
      def on_join
        request.args.first.split(/,(?=[#&+!])/).each do |channel_name|
          channel = Channel.find_or_create(channel_name)
          if channel.join(self)
            channel.broadcast(:join, :source => source, :text => channel.name)
            respond_to_topic(channel)
            respond_to_names(channel)
          end
        end
      end
    end
  end
end
