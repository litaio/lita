require "bundler/gem_tasks"
require "cane/rake_task"
require "rspec/core/rake_task"

Cane::RakeTask.new
RSpec::Core::RakeTask.new

task default: [:spec, :cane]
