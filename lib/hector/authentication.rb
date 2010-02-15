module Hector
  module Authentication
    def on_user
      @username = request.args.first
      @realname = request.text
      authenticate
    end

    def on_pass
      @password = request.text
      authenticate
    end

    def on_nick
      @nickname = request.text
      authenticate
    end

    protected
      def authenticate
        set_identity
        set_session
      end

      def set_identity
        if @username && @password
          @identity = Identity.authenticate(@username, @password)
        end
      end

      def set_session
        if @identity && @nickname
          @session = Session.create(@nickname, self, @identity)
          @session.welcome
        end
      end
  end
end
