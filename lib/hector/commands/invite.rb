module Hector
  module Commands
    module Invite
      def on_invite
        touch_presence
        nickname = request.args.first
        if session = Session.find(nickname)
          channel = Channel.find(request.args[1])
          if channels.include?(channel)
            if !session.channels.include?(channel)
              session.deliver(:invite, self, :source => source, :text => request.text)
            else
              respond_with("443", nickname, channel.name, "is already on channel", :source => Hector.server_name)
            end
          else
            respond_with("442", request.args[1], "You're not on that channel", :source => Hector.server_name)
          end
        else
          raise NoSuchNickOrChannel, nickname
        end        
      end
    end
  end
end