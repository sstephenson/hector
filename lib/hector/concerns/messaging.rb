module Hector
  module Concerns
    module Messaging
      def deliver_message_as(message_type)
        destination, text = request.args.first, request.text
        touch_presence

        if channel?(destination)
          on_channel_message(message_type, destination, text)
        else
          on_session_message(message_type, destination, text)
        end
      end

      def on_channel_message(message_type, channel_name, text)
        if channel = Channel.find(channel_name)
          if channel.has_session?(self)
            channel.broadcast(message_type, channel.name, :source => source, :text => text, :except => self)
          else
            raise CannotSendToChannel, channel_name
          end
        else
          raise NoSuchNickOrChannel, channel_name
        end
      end

      def on_session_message(message_type, nickname, text)
        if session = Session.find(nickname)
          session.respond_with(message_type, nickname, :source => source, :text => text)
        else
          raise NoSuchNickOrChannel, nickname
        end
      end
    end
  end
end
