require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.verbose = true
  t.warning = true

  t.libs = [] unless RUBY_PLATFORM =~ /mswin$|mingw32|mingw64|win32\-|\-win32/
end

task :default => :test
