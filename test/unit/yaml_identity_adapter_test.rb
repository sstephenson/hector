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
      assert_authenticated "sam", "secret"
    end

    test :"failed authentication" do
      assert_not_authenticated "sam", "bananas"
    end

    test :"usernames are case-insensitive" do
      assert_authenticated "SAM", "secret"
    end

    test :"creating a new identity" do
      assert_not_authenticated "lee", "waffles"
      adapter.remember("lee", "waffles")
      assert_authenticated "lee", "waffles"
      reload_adapter
      assert_authenticated "lee", "waffles"
    end

    test :"deleting an existing identity" do
      adapter.forget("sam")
      assert_not_authenticated "sam", "secret"
      reload_adapter
      assert_not_authenticated "sam", "secret"
    end

    test :"changing the password of an existing identity" do
      adapter.remember("sam", "bananas")
      assert_authenticated "sam", "bananas"
      reload_adapter
      assert_authenticated "sam", "bananas"
    end

    test :"yaml file is automatically created if it doesn't exist" do
      teardown
      assert !File.exists?(TEST_IDENTITY_FIXTURES)
      reload_adapter
      assert_not_authenticated "sam", "secret"
      assert File.exists?(TEST_IDENTITY_FIXTURES)
    end

    def assert_authenticated(username, password, expected = true)
      adapter.authenticate(username, password) do |authenticated|
        assert_equal expected, authenticated
      end
    end

    def assert_not_authenticated(username, password)
      assert_authenticated(username, password, false)
    end
  end
end
