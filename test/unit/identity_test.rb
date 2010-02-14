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
  end
end
