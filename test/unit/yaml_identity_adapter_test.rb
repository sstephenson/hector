module Hector
  class YamlIdentityAdapterTest < TestCase
    TEST_IDENTITY_FIXTURES = Hector.fixture_path("identities2.yml")

    attr_reader :adapter

    def setup
      FileUtils.cp(IDENTITY_FIXTURES, TEST_IDENTITY_FIXTURES)
      reload_adapter
    end

    def teardown
      FileUtils.rm_f(TEST_IDENTITY_FIXTURES)
    end

    def reload_adapter
      @adapter = YamlIdentityAdapter.new(TEST_IDENTITY_FIXTURES)
    end

    test :"successful authentication" do
      assert adapter.authenticate("sam", "secret")
    end

    test :"failed authentication" do
      assert !adapter.authenticate("sam", "bananas")
    end

    test :"usernames are case-insensitive" do
      assert adapter.authenticate("SAM", "secret")
    end

    test :"creating a new identity" do
      assert !adapter.authenticate("lee", "waffles")
      adapter.remember("lee", "waffles")
      assert adapter.authenticate("lee", "waffles")
      reload_adapter
      assert adapter.authenticate("lee", "waffles")
    end

    test :"deleting an existing identity" do
      adapter.forget("sam")
      assert !adapter.authenticate("sam", "secret")
      reload_adapter
      assert !adapter.authenticate("sam", "secret")
    end

    test :"changing the password of an existing identity" do
      adapter.remember("sam", "bananas")
      assert adapter.authenticate("sam", "bananas")
      reload_adapter
      assert adapter.authenticate("sam", "bananas")
    end

    test :"yaml file is automatically created if it doesn't exist" do
      teardown
      assert !File.exists?(TEST_IDENTITY_FIXTURES)
      reload_adapter
      assert !adapter.authenticate("sam", "secret")
      assert File.exists?(TEST_IDENTITY_FIXTURES)
    end
  end
end
