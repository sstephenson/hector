module Hector
  class Request
    attr_reader  :line, :command, :args, :text
    alias_method :to_s, :line

    def initialize(line)
      @line = line
      parse
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

        if @text
          @args.push(@text)
        else
          @text = @args.last
        end
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
