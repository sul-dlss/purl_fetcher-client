lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'purl_fetcher/client/version'

Gem::Specification.new do |spec|
  spec.name          = 'purl_fetcher-client'
  spec.version       = PurlFetcher::Client::VERSION
  spec.authors       = [ "Chris Beer" ]
  spec.email         = [ "cabeer@stanford.edu" ]

  spec.summary       = 'Traject-compatible reader implementation for streaming data from purl-fetcher'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = [ "lib" ]

  spec.add_dependency 'activesupport'
  spec.add_dependency 'faraday', '~> 2.1'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'debug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'webmock'
end
