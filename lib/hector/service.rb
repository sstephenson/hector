module Hector
  class Service < Session
    def reply_to(response, options = {})
      EM.defer do
        destination_for_reply(response).deliver(response.command, self, { :source => source }.merge(options))
      end
    end

    def destination_for_reply(response)
      sender = find(response.source[/^(.+?)!/, 1])
      recipient = find(response.args.first)
      recipient == self ? sender : recipient
    end
  end
end
