module Hector
  class Connection < EventMachine::Protocols::LineAndTextProtocol
    include Concerns::Authentication

    attr_reader :session, :request, :identity

    def post_init
      log(:info, "opened connection")
    end

    def receive_line(line)
      @request = Request.new(line)
      log(:debug, "received", @request.to_s.inspect) unless @request.sensitive?

      if session
        session.receive(request)
      else
        if respond_to?(request.event_name)
          send(request.event_name)
        else
          close_connection(true)
        end
      end

    rescue IrcError => e
      handle_error(e)

    rescue Exception => e
      log(:error, [e, *e.backtrace].join("\n"))

    ensure
      @request = nil
    end

    def unbind
      session.destroy if session
      log(:info, "closing connection")
    end

    def respond_with(response, *args)
      response = Response.new(response, *args) unless response.is_a?(Response)
      send_data(response.to_s)
      log(:debug, "sent", response.to_s.inspect)
    end

    def handle_error(error)
      respond_with(error.response)
      close_connection(true) if error.fatal?
    end

    def error(klass, *args)
      handle_error(klass.new(*args))
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
      start_tls(ssl_options)
    end

    private
      def ssl_options
        { :cert_chain_file => Hector.ssl_certificate_path.to_s,
          :private_key_file => Hector.ssl_certificate_key_path.to_s }
      end
  end
end
