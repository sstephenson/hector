module Hector
  module Commands
    module Notice
      def on_notice
        deliver_message_as(:notice)
      end
    end
  end
end
