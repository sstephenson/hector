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

    def receive_line(*)
      super
      Hector.process_deferred_blocks
    end

    def address
      "test"
    end

    def port
      0
    end
    
    def start_timeout
      @timer ||= Object.new.tap do |o|
        def o.cancel; end
      end
    end
  end
end
