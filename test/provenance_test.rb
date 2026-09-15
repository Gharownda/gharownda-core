# frozen_string_literal: true

require_relative "test_helper"

class ProvenanceTest < Minitest::Test
  Reference = Gharownda::Core::Provenance::Reference
  Edge = Gharownda::Core::Provenance::Edge
  Graph = Gharownda::Core::Provenance::Graph

  def ref(type, id, metadata: {})
    Reference.new(type: type, id: id, metadata: metadata)
  end

  def test_reference_identity_ignores_metadata
    first = ref(:message, 12, metadata: { title: "First" })
    second = ref("message", "12", metadata: { title: "Updated" })

    assert_equal first, second
    assert_equal first.hash, second.hash
    assert_equal [ "message", "12" ], first.key
  end

  def test_reference_rejects_blank_identity_parts
    assert_raises(ArgumentError) { ref("", 1) }
    assert_raises(ArgumentError) { ref(:item, " ") }
  end

  def test_edge_rejects_self_reference_and_blank_relation
    source = ref(:record, 1)

    assert_raises(ArgumentError) { Edge.new(source: source, target: source, relation: :derived_from) }
    assert_raises(ArgumentError) { Edge.new(source: source, target: ref(:record, 2), relation: " ") }
  end

  def test_duplicate_edges_are_idempotent
    source = ref(:source, 1)
    target = ref(:target, 2)
    graph = Graph.new

    graph.add_edge(source: source, target: target, relation: :derived_from)
    graph.add_edge(source: source, target: target, relation: "derived_from", metadata: { retry: true })

    assert_equal 1, graph.edges.size
    assert_equal 2, graph.references.size
  end

  def test_incoming_outgoing_and_relation_filters
    source = ref(:source, 1)
    converted = ref(:target, 2)
    copied = ref(:target, 3)
    graph = Graph.new
      .add_edge(source: source, target: converted, relation: :converted_to)
      .add_edge(source: source, target: copied, relation: :copied_to)

    assert_equal 2, graph.outgoing(source).size
    assert_equal [ converted ], graph.outgoing(source, relation: :converted_to).map(&:target)
    assert_equal [ source ], graph.incoming(copied).map(&:source)
  end

  def test_reachability_traverses_multiple_edges
    original = ref(:record, "a")
    intermediate = ref(:record, "b")
    final = ref(:record, "c")
    unrelated = ref(:record, "d")
    graph = Graph.new
      .add_edge(source: original, target: intermediate, relation: :derived_from)
      .add_edge(source: intermediate, target: final, relation: :derived_from)

    assert graph.reachable?(from: original, to: final)
    assert graph.reachable?(from: original, to: final, relation: :derived_from)
    refute graph.reachable?(from: original, to: unrelated)
  end

  def test_cycle_detection
    first = ref(:record, 1)
    second = ref(:record, 2)
    third = ref(:record, 3)
    graph = Graph.new
      .add_edge(source: first, target: second, relation: :next)
      .add_edge(source: second, target: third, relation: :next)

    assert graph.acyclic?

    graph.add_edge(source: third, target: first, relation: :next)

    assert graph.cycle?
  end

  def test_serialization_round_trip
    source = ref(:message, 42, metadata: { "label" => "source" })
    target = ref(:task, "abc")
    graph = Graph.new.add_edge(
      source: source,
      target: target,
      relation: :converted_to,
      metadata: { reason: "user-requested" }
    )

    restored = Graph.from_h(graph.to_h)

    assert_equal graph.to_h, restored.to_h
    assert restored.reachable?(from: ref(:message, 42), to: ref(:task, "abc"))
  end
end
