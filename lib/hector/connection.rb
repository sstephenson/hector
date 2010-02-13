module Hector
  class Connection < EventMachine::Protocols::LineAndTextProtocol
    attr_reader :session, :request, :identity

    def receive_line(line)
      puts(line)
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
      set_identity
    end

    def on_pass
      @password = request.text
      set_identity
    end

    def on_nick
      @nickname = request.text
    end

    def unbind
      session.unbind if session
    end

    protected
      def set_identity
        if @username && @password
          unless @identity = Identity.authenticate(@username, @password)
            respond_with(464, :text => "Password incorrect")
            close_connection(true)
          else
            respond_with("001", :text => "Welcome to IRC bitches")
          end
        end
      end
  end
end
