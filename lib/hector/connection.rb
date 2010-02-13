module Hector
  class Connection < EventMachine::Protocols::LineAndTextProtocol
    attr_reader :session, :request, :identity

    def receive_line(line)
      @request = Request.new(line)
      if session
        session.receive(request)
      else
        if respond_to?(request.event_name)
          send(request.event_name)
        else
          close_connection
        end
      end
    ensure
      @request = nil
    end

    def respond_with(command, *args)
      args.push(":#{args.pop[:text]}") if args.last.is_a?(Hash)
      send_data([command.to_s.upcase, *args].join(" ") + "\r\n")
    end

    def on_user
      @username = request.args.first
      @realname = request.text
      authenticate
    end

    def on_pass
      @password = request.text
      authenticate
    end

    def on_nick
      @nickname = request.text
      authenticate
    end

    def unbind
      session.destroy if session
    end

    protected
      def authenticate
        set_identity
        set_session
      end

      def set_identity
        if @username && @password
          unless @identity = Identity.authenticate(@username, @password)
            respond_with("464", :text => "Password incorrect")
            close_connection(true)
          end
        end
      end

      def set_session
        if @identity && @nickname
          @session = Session.create(self, @identity, @nickname)
          @session.welcome
        end
      end
  end
end
