module Hector
  module Commands
    module Privmsg
      def on_privmsg
        touch_presence
        subject = find(request.args.first)

        subject.deliver(:privmsg, self, :source => source, :text => request.text)

        if !subject.channel? and subject.away?
          respond_with("301", subject.nickname, :text => subject.away_message)
        end
      end
    end
  end
end
