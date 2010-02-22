module Hector
  class Response
    attr_reader :command, :args, :source
    attr_accessor :text

    def initialize(command, *args)
      @command = command.to_s.upcase
      @args = args

      options = args.pop if args.last.is_a?(Hash)
      @text = options[:text] if options
      @source = options[:source] if options
    end

    def to_s
      [].tap do |line|
        line.push(":#{source}") if source
        line.push(command)
        line.concat(args)
        line.push(":#{text}") if text
      end.join(" ")[0, 510] + "\r\n"
    end
    
    def self.apportion(args, *base_args)
      [].tap do |responses|
        base_response = Response.new(*base_args)
        unprocessed_args = args.reverse
        while unprocessed_args.length > 0
          this_response_text = []
          while response_fits?(base_response, this_response_text + [unprocessed_args.last])
            this_response_text << unprocessed_args.pop
          end
          this_response = base_response.dup
          this_response.text = this_response_text.join(" ")
          responses << this_response
        end
      end
    end
    
    private
      def self.response_fits?(base_response, text)
        (base_response.to_s.length + text.join(" ").length) <= 510
      end
  end
end
