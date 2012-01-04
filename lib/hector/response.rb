module Hector
  class Response
    attr_reader :command, :args, :source
    attr_accessor :text

    class << self
      def apportion_text(args, *base_args)
        base_response = Response.new(*base_args)
        max_length = 510 - base_response.to_s.bytesize

        args.inject([args.shift.dup]) do |texts, arg|
          if texts.last.bytesize + arg.bytesize + 1 >= max_length
            texts << arg.dup
          else
            texts.last << " " << arg
          end
          texts
        end.map do |text|
          base_response.dup.tap do |response|
            response.text = text
          end
        end
      end
    end

    def initialize(command, *args)
      @command = command.to_s.upcase
      @args = args
      
      options = args.pop if args.last.is_a?(Hash)
      @text = options[:text] if options
      @source = options[:source] if options
      @source ||= Hector.server_name if @command =~ /^\d+$/
    end

    def event_name
      "received_#{command.downcase}"
    end

    def to_s
      [].tap do |line|
        line.push(":#{source}") if source
        line.push(command)
        line.concat(args)
        line.push(":#{text}") if text
      end.map do |arg|
        if arg.respond_to?(:force_encoding) then arg.force_encoding("UTF-8") else arg end
      end.join(" ")[0, 510] + "\r\n"
    end
  end
end
