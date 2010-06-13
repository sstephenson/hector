module Hector
  module Commands
    module Realname
      def on_realname
        @realname = request.text
        broadcast("352", name, who)
      end
    end
  end
end
