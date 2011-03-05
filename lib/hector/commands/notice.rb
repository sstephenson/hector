module Hector
  module Commands
    module Notice
      def on_notice
        touch_presence
        find(request.args.first).deliver(:notice, self, :source => source, :text => request.text)
      end
    end
  end
end
