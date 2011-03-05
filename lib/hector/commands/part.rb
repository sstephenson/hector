# encoding: UTF-8

module Hector
  module Commands
    module Part
      def on_part
        channel = Channel.find(request.args.first)
        channel.broadcast(:part, channel.name, :source => source, :text => request.text)
        channel.part(self)
      end
    end
  end
end
