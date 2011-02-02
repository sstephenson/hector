module Hector
  module Commands
    module Whois
      def on_whois
        nickname = request.args.first
        if session = Session.find(nickname)
          respond_to_whois_for(self.nickname, session)
        else
          raise NoSuchNickOrChannel, nickname
        end
      ensure
        respond_with("318", self.nickname, nickname, "End of /WHOIS list.")
      end

      def respond_to_whois_for(destination, session)
        respond_with("301", session.nickname, :text => session.away_message) if session.away?
        respond_with("311", destination, session.nickname, session.whois)
        respond_with("319", destination, session.nickname, :text => session.channels.map { |channel| channel.name }.join(" ")) unless channels.empty?
        respond_with("312", destination, session.nickname, Hector.server_name, :text => "Hector")
        respond_with("317", destination, session.nickname, session.seconds_idle, session.created_at, :text => "seconds idle, signon time")
      end

      def whois
        "#{nickname} #{identity.username} #{Hector.server_name} * :#{realname}"
      end
    end
  end
end
