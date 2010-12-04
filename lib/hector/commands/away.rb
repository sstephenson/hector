module Hector
  module Commands
    module Away
      def on_away
        away_message = request.args.first
        if away_message and !away_message.empty?
          @away_message = away_message
          respond_with("306", :text => "You have been marked as being away")
        else
          @away_message = nil
          respond_with("305", :text => "You are no longer marked as being away")
        end
      end
    end
  end
end
