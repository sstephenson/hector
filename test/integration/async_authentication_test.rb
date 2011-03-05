require "test_helper"
require "hector/async_identity_adapter"

module Hector
  class AsyncAuthenticationTest < IntegrationTest
    def setup
      super
      @yaml_identity_adapter = Identity.adapter
      Identity.adapter = AsyncIdentityAdapter.new(IDENTITY_FIXTURES)
    end

    def teardown
      super
      Identity.adapter = @yaml_identity_adapter
    end

    test :"connecting with an invalid password" do
      connection.tap do |c|
        pass! c, "invalid"
        user! c
        nick! c

        assert_nil c.session
        assert_invalid_password c
        assert_closed c
      end
    end

    test :"connecting with a nonexistent username" do
      connection.tap do |c|
        pass! c, "invalid"
        user! c, "invalid"

        assert_nil c.session
        assert_invalid_password c
        assert_closed c
      end
    end

    test :"connecting with a valid username and password" do
      connection.tap do |c|
        pass! c
        user! c
        nick! c

        assert_not_nil c.session
        assert_welcomed c
        assert_not_closed c
      end
    end
  end
end
