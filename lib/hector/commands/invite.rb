module Hector
  module Commands
    module Invite
      def on_invite
        touch_presence
        subject = find(request.args.first)
        subject.deliver(:invite, self, :source => source, :text => request.text)
      end
    end
  end
end