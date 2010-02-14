module Hector
  class Error < ::StandardError; end

  class IrcError < Error
    def response
      returning Response.new(command, *options) do |response|
        response.args.push(message) unless message == self.class.name
      end
    end
  end

  def self.IrcError(command, *options)
    fatal = options.last.is_a?(Hash) && options.last.delete(:fatal)
    returning Class.new(IrcError) do |klass|
      klass.class_eval do
        define_method(:command) { command.dup }
        define_method(:options) { options.dup }
        define_method(:fatal?) { fatal }
      end
    end
  end

  class InvalidPassword   < IrcError("464", :text => "Invalid password", :fatal => true); end
  class ErroneousNickname < IrcError("432", :text => "Erroneous nickname"); end
  class NicknameInUse     < IrcError("433", :text => "Nickname is already in use"); end
end
