# encoding: utf-8

Gem::Specification.new do |gem|
  gem.name    = "figaro"
  gem.version = "0.6.0"

  gem.authors     = ["Steve Richert"]
  gem.email       = ["steve.richert@gmail.com"]
  gem.summary     = "Simple Rails app configuration"
  gem.description = "Simple, Heroku-friendly Rails app configuration using ENV and a single YAML file"
  gem.homepage    = "https://github.com/laserlemon/figaro"

  gem.add_dependency "rails", ">= 3", "< 5"

  gem.add_development_dependency "aruba", "~> 0.5.1"
  gem.add_development_dependency "cucumber", "~> 1.2.1"
  gem.add_development_dependency "rake", ">= 0.8.7"
  gem.add_development_dependency "rspec", "~> 2.12.0"

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(/^(features|gemfiles|spec)/)
  gem.require_paths = ["lib"]
end
