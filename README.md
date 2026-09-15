# Gharownda Core

Gharownda Core is the public open-source home for small, genuinely reusable building blocks used across software that needs durable provenance and linking.

The first shipped capability is a dependency-free Ruby provenance library. It provides typed object references, directed relation edges, graph traversal, cycle detection, and deterministic serialization without depending on Rails or any Gharownda product model.

## Installation

The gem is not published to RubyGems yet. From GitHub, add:

```ruby
gem "gharownda-core", github: "Gharownda/gharownda-core"
```

Then require the library:

```ruby
require "gharownda/core"
```

## Provenance API

```ruby
include Gharownda::Core::Provenance

source = Reference.new(type: :message, id: 42)
target = Reference.new(type: :task, id: "abc")

graph = Graph.new
graph.add_edge(
  source: source,
  target: target,
  relation: :converted_to,
  metadata: { reason: "user-requested" }
)

graph.reachable?(from: source, to: target) # => true
graph.acyclic?                              # => true
serialized = graph.to_h
restored = Graph.from_h(serialized)
```

Reference identity is based on `type` + `id`; metadata does not alter identity. Edge identity is based on source, relation, and target, so adding the same logical edge repeatedly is idempotent. Graphs may represent cyclic relationships, while `cycle?` / `acyclic?` let callers enforce stricter domain rules when needed.

## Development

```bash
bundle install
bundle exec rake test
gem build gharownda-core.gemspec
```

CI runs the library suite on Ruby 3.3 and 3.4 and also verifies that the gem builds successfully.

## Extraction rule

Components belong here only when they have a genuine reusable boundary and can be documented and tested independently. Private product source, plans, data models, prompts, credentials, and product-specific policy do not belong in this repository.

Potential future areas include provider-neutral interfaces, generic policy helpers, and additional provenance adapters when a real reusable need exists.
