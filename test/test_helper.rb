begin
  require "hector"
  require "test/unit"
  require "mocha"
rescue LoadError => e
  if require "rubygems"
    retry
  else
    raise e
  end
end

module Hector
  def self.fixture_path(filename)
    File.join(File.dirname(__FILE__), "fixtures", filename)
  end

  Identity.filename = fixture_path("identities.yml")

  class TestCase < Test::Unit::TestCase
    undef_method :default_test

    def self.test(name, &block)
      define_method("test #{name.inspect}", &block)
    end

    def connection
      Hector::TestConnection.new("test")
    end

    def identity(username = "sam")
      Hector::Identity.find(username)
    end
  end

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
