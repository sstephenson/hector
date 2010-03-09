module Hector
  module Commands
    module Privmsg
      def on_privmsg
        touch_presence
        find(request.args.first).deliver(:privmsg, self, :source => source, :text => request.text)
      end
    end
  end
end
