module Hector
  class Response
    attr_reader :command, :args, :text

    def initialize(command, *args)
      @command = command.to_s
      @args = args
      options = args.pop if args.last.is_a?(Hash)
      @text = options[:text] if options
    end

    def to_s
      @to_s ||= returning([command]) do |line|
        line.concat(args)
        line.push(":#{text}") if text
      end.join(" ")[0, 510] + "\r\n"
    end
  end
end
