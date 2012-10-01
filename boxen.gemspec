# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name          = "boxen"
  gem.version       = "0.0.0"
  gem.authors       = ["John Barnette", "Will Farrington"]
  gem.email         = ["jbarnette@github.com", "wfarr@github.com"]
  gem.description   = "Manage development boxes with love (and Puppet)."
  gem.summary       = "You know, for laptops."
  gem.homepage      = "https://github.com/boxen/boxen"

  gem.files         = `git ls-files`.split $/
  gem.test_files    = gem.files.grep /^test/
  gem.require_paths = ["lib"]

  gem.add_development_dependency "minitest", "3.5.0"
  gem.add_development_dependency "mocha"
end
