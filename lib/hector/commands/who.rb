module Hector
  module Commands
    module Who
      def on_who
        destination = request.args.first

        if channel?(destination)
          on_channel_who(destination)
        else
          on_session_who(destination)
        end

        respond_with("315", destination, :text => "End of /WHO list.")
      end

      def on_channel_who(channel_name)
        if channel = Channel.find(channel_name)
          respond_to_who_for(channel_name, channel.sessions)
        end
      end

      def on_session_who(nickname)
        if session = Session.find(nickname)
          respond_to_who_for("*", [session])
        end
      end

      def respond_to_who_for(destination, sessions)
        sessions.each do |session|
          respond_with("352", destination, session.who)
        end
      end

      def who
        "#{identity.username} #{Hector.server_name} #{Hector.server_name} #{nickname} H :0 #{realname}"
      end
    end
  end
end
