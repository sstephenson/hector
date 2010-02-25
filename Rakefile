require "rake/testtask"

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/*/*_test.rb"]
  t.verbose = true
end

begin
  require "rcov/rcovtask"
  
  Rcov::RcovTask.new do |t|
    t.libs << "test"
    t.test_files = FileList["test/*/*_test.rb"]
    t.rcov_opts << "-x 'rcov|eventmachine|mocha'"
    t.verbose = true
  end
rescue LoadError
end

desc "Removes trailing whitespace and replaces tabs with two spaces"
task :whitespace do
  sh %[find . \\( -name '*.rb' -or -name '*.yml' \\) -type f -exec ruby -pi -e 'gsub(/ +$/, "");gsub(/\t/, "  ")' {} \\;]
end
