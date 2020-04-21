# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dmc_kanye/version'

Gem::Specification.new do |spec|
  spec.name          = "dmc_kanye"
  spec.version       = DmcKanye::VERSION
  spec.authors       = ["Wyatt Greene", "Parker Morse"]
  spec.licenses      = ['MIT']
  spec.homepage      = 'https://github.com/dmcouncil/dmc_kanye'

  spec.summary       = %q{Imma let your AJAX finish, but these are the best feature tests of ALL TIME.}
  spec.description   = %q{Kanye improves Capybara's synchronization algorithm by letting the browser finish before the test keeps going. By doing this, Kanye also helps you tailor the swiftness of your feature specs.}

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "capybara", [">= 2.5.0", "~>2.6.2"]
  spec.add_dependency "poltergeist", "~> 1.5"
  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake"
end
