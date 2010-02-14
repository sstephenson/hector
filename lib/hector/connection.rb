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
    rescue IrcError => e
      respond_with(e.response)
      close_connection(true) if e.fatal?
    ensure
      @request = nil
    end

    def respond_with(response, *args)
      response = Response.new(response, *args) unless response.is_a?(Response)
      send_data(response.to_s)
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
      if session
        session.destroy
      end
    end

    protected
      def authenticate
        set_identity
        set_session
      end

      def set_identity
        if @username && @password
          @identity = Identity.authenticate(@username, @password)
        end
      end

      def set_session
        if @identity && @nickname
          @session = Session.create(@nickname, self, @identity)
          @session.welcome
        end
      end
  end
end
