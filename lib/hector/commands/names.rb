module Hector
  module Commands
    module Names
      def on_names
        channel = Channel.find(request.args.first)
        respond_to_names(channel)
      end

      def respond_to_names(channel)
        responses = Response.apportion_text(channel.nicknames, "353", nickname, "=", channel.name, :source => "hector.irc")
        responses.each { |response| respond_with(response) }
        respond_with("366", nickname, channel.name, :source => "hector.irc", :text => "End of /NAMES list.")
      end
    end
  end
end
