module Hector
  class Request
    attr_reader :line, :command, :args, :text

    def initialize(line)
      @line = line
      parse
    end

    def to_s
      line
    end

    def event_name
      "on_#{command.downcase}"
    end

    protected
      def parse
        source = line.dup
        @command = extract!(source, /^ *([^ ]+)/, "").upcase
        @text = extract!(source, / :(.*)$/)
        @args = source.strip.split(" ")
        @text ||= @args.last
      end

      def extract!(line, regex, default = nil)
        result = nil
        line.gsub!(regex) do |match|
          result = $~[1]
          ""
        end
        result || default
      end
  end
end
