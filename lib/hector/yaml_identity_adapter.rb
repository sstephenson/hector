module Hector
  # Identity adapters must implement the following public methods:
  #  - authenticate(username, password)
  #  - remember(username, password)
  #  - forget(username)
  #  - normalize(username)
  #
  class YamlIdentityAdapter
    attr_reader :filename

    def initialize(filename)
      @filename = File.expand_path(filename)
    end

    def authenticate(username, password)
      yield load_identities[normalize(username)] == hash(normalize(username), password)
    end

    def remember(username, password)
      identities = load_identities
      identities[normalize(username)] = hash(normalize(username), password)
      store_identities(identities)
    end

    def forget(username)
      identities = load_identities
      identities.delete(normalize(username))
      store_identities(identities)
    end

    def normalize(username)
      username.strip.downcase
    end

    protected
      def load_identities
        ensure_file_exists
        YAML.load(File.open(filename, "r")) || {}
      end

      def store_identities(identities)
        File.open(filename, "w") do |file|
          file.puts(identities.to_yaml)
        end
      end

      def hash(username, password)
        Digest::SHA1.hexdigest(Digest::SHA1.hexdigest(username) + password)
      end

      def ensure_file_exists
        FileUtils.mkdir_p(File.dirname(filename))
        FileUtils.touch(filename)
      end
  end
end
