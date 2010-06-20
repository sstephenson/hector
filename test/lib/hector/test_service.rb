module Hector
  class TestService < Service
    def received_privmsg
      intercept(/^!reverse (.+)/) do |line, text|
        deliver_message_from_origin(text.reverse)
      end

      intercept(/^!sum (\d+) (\d+)/) do |line, n, m|
        n, m = n.to_i, m.to_i
        deliver_message_from_service("#{n} + #{m} = #{n + m}")
      end
    end

    def defer(&block)
      Hector.defer(&block)
    end
  end
end
