module Hector
  class Connection < EventMachine::Protocols::LineAndTextProtocol
    include Authentication

    attr_reader :session, :request, :identity

    def post_init
      log(:info, "opened connection")
    end

    def receive_line(line)
      @request = Request.new(line)
      log(:debug, "received", @request.to_s.inspect)

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

    rescue Exception => e
      log(:warn, "error:", e)

    ensure
      @request = nil
    end

    def unbind
      if session
        session.destroy
      end
      log(:info, "closing connection")
    end

    def respond_with(response, *args)
      response = Response.new(response, *args) unless response.is_a?(Response)
      send_data(response.to_s)
      log(:debug, "sent", response.to_s.inspect)
    end

    def log(level, *args)
      Hector.logger.send(level, [log_tag, *args].join(" "))
    end

    def address
      peer_info[1]
    end

    def port
      peer_info[0]
    end

    protected
      def peer_info
        @peer_info ||= Socket.unpack_sockaddr_in(get_peername)
      end

      def log_tag
        "[#{address}:#{port}]".tap do |tag|
          tag << " (#{session.nickname})" if session
        end
      end
  end

  class SSLConnection < Connection
    def post_init
      log(:info, "opened SSL connection")
      start_tls
    end
  end
end
