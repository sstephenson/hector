module Hector
  class Error < ::StandardError; end

  class IrcError < Error
    def response
      Response.new(command, *options).tap do |response|
        response.args.push(message) unless message == self.class.name
      end
    end
  end

  def self.IrcError(command, *options)
    fatal = options.last.is_a?(Hash) && options.last.delete(:fatal)
    Class.new(IrcError).tap do |klass|
      klass.class_eval do
        define_method(:command) { command.dup }
        define_method(:options) { options.dup }
        define_method(:fatal?) { fatal }
      end
    end
  end

  class NoSuchNickOrChannel < IrcError("401", :text => "No such nick/channel"); end
  class NoSuchChannel       < IrcError("403", :text => "No such channel"); end
  class CannotSendToChannel < IrcError("404", :text => "Cannot send to channel"); end
  class ErroneousNickname   < IrcError("432", :text => "Erroneous nickname"); end
  class NicknameInUse       < IrcError("433", :text => "Nickname is already in use"); end
  class InvalidPassword     < IrcError("464", :text => "Invalid password", :fatal => true); end
end
