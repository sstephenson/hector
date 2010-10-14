module Hector
  module Commands
    module Privmsg
      def on_privmsg
        touch_presence
        subject = find(request.args.first)

        if subject.away?
          respond_with("301", name, subject.nickname, :text => subject.away_message)
        end

        subject.deliver(:privmsg, self, :source => source, :text => request.text)
      end
    end
  end
end
