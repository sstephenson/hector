module Hector
  module Commands
    module Nick
      def on_nick
        old_nickname = nickname
        rename(request.args.first)
        broadcast(:nick, nickname, :source => old_nickname)
      end
    end
  end
end
