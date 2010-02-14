require "test_helper"

module Hector
  class IdentityTest < TestCase
    def setup
      Identity.reset!
    end

    def teardown
      Identity.filename = Hector.fixture_path("identities.yml")
    end

    test :"authentication of passwords" do
      assert identity.authenticate("secret")
      assert !identity.authenticate("bananas")
    end

    test :"find doesn't raise when the identities file contains bad yaml" do
      Identity.filename = Hector.fixture_path("empty_file")

      assert !YAML.load_file(Identity.filename).is_a?(Hash)

      assert_nothing_raised do
        Identity.find("sam")
      end
    end

    test :"find doesn't raise when the filename isn't present" do
      Identity.filename = File.dirname(__FILE__) + "/nonexistent"

      assert !File.exists?(Identity.filename)

      assert_nothing_raised do
        Identity.find("sam")
      end
    end

    test :"identities file is cached" do
      Identity.find("sam")
      Identity.filename = Hector.fixture_path("identities2.yml")
      assert Identity.find("sam")
      assert Identity.find("clint")

      Identity.reset!
      assert !Identity.find("sam")
      assert Identity.find("clint")
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
  end
end
