module Hector
  class TestConnection < Connection
    def sent_data
      @sent_data ||= ""
    end

    def send_data(data)
      sent_data << data
    end

    def connection_closed?
      @connection_closed
    end

    def close_connection(after_writing = false)
      unbind unless connection_closed?
      @connection_closed = true
    end

    def get_peername
      "\020\002\346\075\177\000\000\001\000\000\000\000\000\000\000\000"
    end
  end
end
