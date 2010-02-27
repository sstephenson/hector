module Hector
  module Commands
    module Privmsg
      def on_privmsg
        deliver_message_as(:privmsg)
      end
    end
  end
end
