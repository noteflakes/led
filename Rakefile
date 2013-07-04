require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |config|
  config.rspec_opts = '-r ./spec/spec_helper'
end

task :default => :spec
