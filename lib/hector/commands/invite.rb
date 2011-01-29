module Hector
  module Commands
    module Invite
      def on_invite
        touch_presence
        nickname = request.args.first
        if session = Session.find(nickname)
          channel_name = request.args[1]
          channel = Channel.find(channel_name)
          if Channel.find_all_for_session(self).include?(channel)
            if !Channel.find_all_for_session(session).include?(channel)
              session.deliver(:invite, self, :source => source, :text => request.text)
            else
              respond_with("443", nickname, channel_name, "is already on channel", :source => Hector.server_name)
            end
          else
            respond_with("442", channel_name, "You're not on that channel", :source => Hector.server_name)
          end
        else
          raise NoSuchNickOrChannel, nickname
        end        
      end
    end
  end
end