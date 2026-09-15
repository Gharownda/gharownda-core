# frozen_string_literal: true

require_relative "lib/gharownda/core/version"

Gem::Specification.new do |spec|
  spec.name = "gharownda-core"
  spec.version = Gharownda::Core::VERSION
  spec.authors = [ "Gharownda contributors" ]
  spec.summary = "Small reusable primitives for provenance and linking"
  spec.description = "Product-neutral Ruby primitives for typed references, provenance edges, and graph traversal."
  spec.homepage = "https://github.com/Gharownda/gharownda-core"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3"

  spec.files = Dir["lib/**/*", "README.md", "LICENSE"]
  spec.require_paths = [ "lib" ]

  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/releases"
end
