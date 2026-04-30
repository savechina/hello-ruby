# frozen_string_literal: true

require_relative "lib/hello/version"

Gem::Specification.new do |spec|
  spec.name          = "hello_ruby"
  spec.version       = Hello::VERSION
  spec.authors       = ["RenYan Wei"]
  spec.email         = ["weirenyan@hotmail.com"]

  spec.summary       = "A Ruby learning project — from basic syntax to production patterns."
  spec.homepage      = "https://github.com/savechina/hello-ruby"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.2.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/savechina/hello-ruby.git"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{\A(?:spec|test|script)/}) ||
        f.match(%r{\A(?:\.opencode|\.sisyphus|\.specify|\.github|docs|target)/}) ||
        f.match(/\A(?:AGENTS\.md|CHANGELOG\.md|\.ignore)/)
    end
  end

  spec.bindir        = "exe"
  spec.executables   = ["hello"]
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "thor", "~> 1.1"
  spec.add_dependency "dry-system", "~> 1.0"
  spec.add_dependency "dry-struct", "~> 1.6"
  spec.add_dependency "dry-events", "~> 1.0"
  spec.add_dependency "dry-monitor", "~> 1.0"
  spec.add_dependency "config", "~> 4.0"
  spec.add_dependency "dotenv", "~> 3.1"
  spec.add_dependency "sequel", "~> 5.54"
  spec.add_dependency "sqlite3", ">= 1.4.2"
  spec.add_dependency "ruby-enum", "~> 1.0"
  spec.add_dependency "factory_bot", "~> 6.2"
end
