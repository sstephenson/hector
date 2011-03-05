# encoding: UTF-8

module Hector
  class Service < Session
    protected
      def deliver_message_from_origin(text)
        deliver_message_from_session(origin, text)
      end

      def deliver_message_from_service(text)
        deliver_message_from_session(self, text)
      end

      def deliver_message_from_session(session, text)
        command, destination = response.command, find(response.args.first)
        Hector.defer do
          destination.deliver(command, session, :source => session.source, :text => text)
        end
      end

      def intercept(pattern)
        if response.text =~ pattern
          yield *$~
          throw :stop
        end
      end

      def origin
        find(response.source[/^([^!]+)!/, 1])
      end
  end
end
