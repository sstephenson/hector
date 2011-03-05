# encoding: UTF-8

module Hector
  class AsyncIdentityAdapter < YamlIdentityAdapter
    def authenticate(username, password)
      Hector.next_tick do
        super username, password
      end
    end
  end
end
