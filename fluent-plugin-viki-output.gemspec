# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fluent/plugin/viki/version'

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-viki-output"
  spec.version       = Fluent::Viki::VERSION
  spec.authors       = ["Casey Vu"]
  spec.email         = ["vuanhthu888@gmail.com"]

  spec.summary       = %q{Viki's custom fluentd output plugin.}
  spec.description   = %q{Viki's custom fluentd output plugin.}
  spec.homepage      = "https://github.com/viki-org/fluent-plugin-out-viki"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency 'test-unit'

  spec.add_dependency "maxminddb", "~> 0.1"
  spec.add_dependency "fluentd", "~> 0.12", "< 0.13"

  spec.license = 'Apache-2.0'
end