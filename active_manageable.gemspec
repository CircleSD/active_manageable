# frozen_string_literal: true

# load a file relative to the current location
require_relative "lib/active_manageable/version"

Gem::Specification.new do |spec|
  spec.name = "active_manageable"
  spec.version = ActiveManageable::VERSION
  spec.authors = ["Chris Hilton", "Chris Branson"]
  spec.email = ["449774+chrismhilton@users.noreply.github.com", "138595+chrisbranson@users.noreply.github.com"]

  spec.summary = "Business logic framework for Ruby on Rails"
  spec.description = "Framework for business logic classes in a Ruby on Rails application"
  spec.homepage = "https://github.com/CircleSD/active_manageable"
  spec.license = "MIT"

  # Minimum version of Ruby compatible with Rails 7.0
  spec.required_ruby_version = ">= 2.7.0"

  # Metadata used on gem’s profile page on rubygems.org
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/CircleSD/active_manageable/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/CircleSD/active_manageable/issues"
  spec.metadata["documentation_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end

  # Binary folder where the gem’s executables are located
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }

  # Add lib directory to $LOAD_PATH to make code available via the require statement
  spec.require_paths = ["lib"]

  # Register runtime and development dependencies
  # including gems that are essential to test and build this gem

  # rails dependencies
  spec.add_dependency "activerecord", ">= 6.0"
  spec.add_dependency "activesupport", ">= 6.0"

  # gem dependencies
  spec.add_dependency "rails-i18n"
  spec.add_dependency "flexitime", "~> 1.0"

  # test dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "sqlite3", "~> 1.4.0"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "rails-controller-testing"
  spec.add_development_dependency "factory_bot_rails"
  spec.add_development_dependency "shoulda-matchers"
  spec.add_development_dependency "simplecov"

  # test modules
  spec.add_development_dependency "pundit"
  spec.add_development_dependency "cancancan"
  spec.add_development_dependency "ransack"
  spec.add_development_dependency "kaminari"

  # linter dependencies
  spec.add_development_dependency "rubocop", "1.23.0"
  spec.add_development_dependency "standard"
  spec.add_development_dependency "rubocop-rails"
  spec.add_development_dependency "rubocop-rspec"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
