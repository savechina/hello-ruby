# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

namespace :rubocop do
  desc "Run rubocop"
  task :run do
    sh "bundle exec rubocop"
  end
end

task default: %i[spec]
