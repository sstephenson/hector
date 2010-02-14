require "rake/testtask"
require "rcov/rcovtask"

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/*/*_test.rb"]
  t.verbose = true
end

Rcov::RcovTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/*/*_test.rb"]
  t.rcov_opts << "-x 'rcov|eventmachine|mocha'"
  t.verbose = true
end
