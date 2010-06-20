module Hector
  module Commands
    module Realname
      def on_realname
        @realname = request.text
        broadcast("352", :$nickname, "*", who, :source => Hector.server_name)
      end
    end
  end
end
