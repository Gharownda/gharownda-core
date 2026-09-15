# frozen_string_literal: true

module Gharownda
  module Core
    module Provenance
      class Graph
        include Enumerable

        def initialize(edges = [])
          @edges_by_key = {}
          @references = {}
          edges.each { |edge| add(edge) }
        end

        def add(edge)
          raise ArgumentError, "edge must be an Edge" unless edge.is_a?(Edge)

          @edges_by_key[edge.key] ||= edge
          @references[edge.source.key] ||= edge.source
          @references[edge.target.key] ||= edge.target
          self
        end

        def add_edge(source:, target:, relation:, metadata: {})
          add(Edge.new(source: source, target: target, relation: relation, metadata: metadata))
        end

        def each(&block)
          edges.each(&block)
        end

        def edges
          @edges_by_key.values.freeze
        end

        def references
          @references.values.freeze
        end

        def outgoing(reference, relation: nil)
          validate_reference!(reference)
          select_edges(source: reference, relation: relation)
        end

        def incoming(reference, relation: nil)
          validate_reference!(reference)
          select_edges(target: reference, relation: relation)
        end

        def reachable?(from:, to:, relation: nil)
          validate_reference!(from)
          validate_reference!(to)
          return true if from == to

          visited = {}
          queue = [ from ]

          until queue.empty?
            current = queue.shift
            next if visited[current.key]

            visited[current.key] = true
            outgoing(current, relation: relation).each do |edge|
              return true if edge.target == to
              queue << edge.target unless visited[edge.target.key]
            end
          end

          false
        end

        def cycle?
          state = {}

          references.any? do |reference|
            visit_cycle(reference, state)
          end
        end

        def acyclic?
          !cycle?
        end

        def to_h
          { "edges" => edges.map(&:to_h) }
        end

        def self.from_h(value)
          raise ArgumentError, "graph must be a Hash" unless value.is_a?(Hash)

          serialized_edges = value["edges"] || value[:edges]
          raise ArgumentError, "graph edges must be an Array" unless serialized_edges.is_a?(Array)

          new(serialized_edges.map { |edge| Edge.from_h(edge) })
        end

        private
          def select_edges(source: nil, target: nil, relation: nil)
            normalized_relation = relation&.to_s&.strip
            edges.select do |edge|
              (!source || edge.source == source) &&
                (!target || edge.target == target) &&
                (!normalized_relation || edge.relation == normalized_relation)
            end.freeze
          end

          def validate_reference!(reference)
            raise ArgumentError, "reference must be a Reference" unless reference.is_a?(Reference)
          end

          def visit_cycle(reference, state)
            current_state = state[reference.key]
            return true if current_state == :visiting
            return false if current_state == :visited

            state[reference.key] = :visiting
            outgoing(reference).each do |edge|
              return true if visit_cycle(edge.target, state)
            end
            state[reference.key] = :visited
            false
          end
      end
    end
  end
end
