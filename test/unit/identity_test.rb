require "test_helper"

module Hector
  class IdentityTest < TestCase
    test :"authentication of passwords" do
      assert Identity.authenticate("sam", "secret")
    end

    test :"authenticate raises when the identity doesn't exist" do
      assert_raises(InvalidPassword) do
        Identity.authenticate("nonexistent", "foo")
      end
    end

    test :"authenticate raises when the password is invalid" do
      assert_raises(InvalidPassword) do
        Identity.authenticate("sam", "foo")
      end
    end

    test :"authenticate returns the authenticated identity" do
      identity = Identity.authenticate("sam", "secret")
      assert_kind_of Identity, identity
      assert_equal "sam", identity.username
    end

    test :"two identities with the same username are equal" do
      assert_equal Identity.new("sam"), Identity.new("sam")
    end

    test :"two identities with different usernames are not equal" do
      assert_not_equal Identity.new("sam"), Identity.new("clint")
    end
  end
end
