module Hector
  module Commands
    module Topic
      def on_topic
        channel = Channel.find(request.args.first)

        if request.args.length > 1
          topic = request.text
          channel.change_topic(self, topic)
          channel.broadcast(:topic, channel.name, :source => source, :text => topic)
        else
          respond_to_topic(channel)
        end
      end

      def respond_to_topic(channel)
        if topic = channel.topic
          respond_with("332", nickname, channel.name, :source => "hector.irc", :text => topic[:body])
          respond_with("333", nickname, channel.name, topic[:nickname], topic[:time].to_i, :source => "hector.irc")
        else
          respond_with("331", nickname, channel.name, :source => "hector.irc", :text => "No topic is set.")
        end
      end
    end
  end
end
