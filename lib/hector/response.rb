module Hector
  class Response
    attr_reader :command, :args, :text, :source

    def initialize(command, *args)
      @command = command.to_s.upcase
      @args = args

      options = args.pop if args.last.is_a?(Hash)
      @text = options[:text] if options
      @source = options[:source] if options
    end

    def to_s
      @to_s ||= [].tap do |line|
        line.push(":#{source}") if source
        line.push(command)
        line.concat(args)
        line.push(":#{text}") if text
      end.join(" ")[0, 510] + "\r\n"
    end
  end
end
