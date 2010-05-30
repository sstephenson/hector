module Hector
  module Commands
    module Mode
      def on_mode
        subject = find(request.args.first)

        if subject.channel?
          if requesting_modes?
            respond_with("324", nickname, subject.name, "+", :source => Hector.server_name)
            respond_with("329", nickname, subject.name, subject.created_at.to_i, :source => Hector.server_name)
          elsif requesting_bans?
            respond_with("368", nickname, subject.name, :text => "End of Channel Ban List", :source => Hector.server_name)
          end
        else
          if requesting_modes?
            respond_with("221", nickname, "+", :source => Hector.server_name)
          end
        end
      end

      private
        def requesting_modes?
          request.args.length == 1
        end

        def requesting_bans?
          request.args.length == 2 && request.args.last[/^\+?b$/]
        end
    end
  end
end
