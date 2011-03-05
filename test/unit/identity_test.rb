require "test_helper"

module Hector
  class IdentityTest < TestCase
    test :"authenticate yields nil when the identity doesn't exist" do
      Identity.authenticate("nonexistent", "foo") do |identity|
        assert_nil identity
      end
    end

    test :"authenticate yields nil when the password is invalid" do
      Identity.authenticate("sam", "foo") do |identity|
        assert_nil identity
      end
    end

    test :"authenticate yields the authenticated identity" do
      Identity.authenticate("sam", "secret") do |identity|
        assert_kind_of Identity, identity
        assert_equal "sam", identity.username
      end
    end

    test :"two identities with the same username are equal" do
      assert_equal Identity.new("sam"), Identity.new("sam")
    end

    test :"two identities with different usernames are not equal" do
      assert_not_equal Identity.new("sam"), Identity.new("clint")
    end
  end
end
