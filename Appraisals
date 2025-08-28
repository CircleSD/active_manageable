# Appraisal integrates with bundler and rake to test your library
# against different versions of dependencies in repeatable scenarios called "appraisals"
# https://github.com/thoughtbot/appraisal
#
# The dependencies in your Appraisals file are combined with dependencies in your Gemfile
#
# Install the dependencies for each appraisal
# $ bundle exec appraisal install
# which generates a Gemfile for each appraisal in the gemfiles directory
#
# Run each appraisal in turn or a single appraisal:-
# $ bundle exec appraisal rspec
# $ bundle exec appraisal rails-7-2 rspec
appraise "rails-7-2" do
  gem "activerecord", "~> 7.2.0"
  gem "activesupport", "~> 7.2.0"
end

appraise "rails-7-1" do
  gem "activerecord", "~> 7.1.0"
  gem "activesupport", "~> 7.1.0"
end

appraise "rails-7-0" do
  gem "activerecord", "~> 7.0.0"
  gem "activesupport", "~> 7.0.0"
  gem "sqlite3", "~> 1.4"
  # cater for gems not shipped as default with Ruby 3.4
  # but required by ActiveSupport
  gem "logger"
  gem "base64"
  gem "bigdecimal"
  gem "mutex_m"
  gem "drb"
  gem "benchmark"
end
