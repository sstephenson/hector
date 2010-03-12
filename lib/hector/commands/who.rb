module Hector
  module Commands
    module Who
      def on_who
        name = request.args.first

        if destination = destination_klass_for(name).find(name)
          sessions_for_who(destination).each do |session|
            respond_with("352", name, session.who)
          end
        end

        respond_with("315", name, :text => "End of /WHO list.")
      end

      def sessions_for_who(destination)
        if destination.respond_to?(:sessions)
          destination.sessions
        else
          [destination]
        end
      end

      def who
        "#{username} #{Hector.server_name} #{Hector.server_name} #{nickname} H :0 #{realname}"
      end
    end
  end
end
