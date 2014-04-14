# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name          = "boxen"
  gem.version       = "2.6.0"
  gem.authors       = ["John Barnette", "Will Farrington", "David Goodlad"]
  gem.email         = ["jbarnette@github.com", "wfarr@github.com", "dgoodlad@github.com"]
  gem.description   = "Manage Mac development boxes with love (and Puppet)."
  gem.summary       = "You know, for laptops and stuff."
  gem.homepage      = "https://github.com/boxen/boxen"

  gem.files         = `git ls-files`.split $/
  gem.test_files    = gem.files.grep /^test/
  gem.require_paths = ["lib"]

  gem.add_dependency "ansi",             "~> 1.4"
  gem.add_dependency "hiera",            "~> 1.0"
  gem.add_dependency "highline",         "~> 1.6"
  gem.add_dependency "json_pure",        [">= 1.7.7", "< 2.0"]
  gem.add_dependency "librarian-puppet", "~> 1.0.0"
  gem.add_dependency "octokit",          "~> 2.7", ">= 2.7.1"
  gem.add_dependency "puppet",           "~> 3.0"

  gem.add_development_dependency "minitest", "4.4.0" # pinned for mocha
  gem.add_development_dependency "mocha",    "~> 0.13"
end
