# frozen_string_literal: true

module Gharownda
  module Core
    module Provenance
      class Edge
        attr_reader :source, :target, :relation, :metadata

        def initialize(source:, target:, relation:, metadata: {})
          raise ArgumentError, "source must be a Reference" unless source.is_a?(Reference)
          raise ArgumentError, "target must be a Reference" unless target.is_a?(Reference)
          raise ArgumentError, "self-referential provenance edges are not allowed" if source == target
          raise ArgumentError, "metadata must be a Hash" unless metadata.is_a?(Hash)

          @source = source
          @target = target
          @relation = normalize_relation(relation)
          @metadata = metadata.each_with_object({}) { |(key, value), copy| copy[key.to_s] = value }.freeze
          freeze
        end

        def key
          [ source.key, relation, target.key ].freeze
        end

        def ==(other)
          other.is_a?(Edge) && other.key == key
        end
        alias eql? ==

        def hash
          key.hash
        end

        def to_h
          result = {
            "source" => source.to_h,
            "target" => target.to_h,
            "relation" => relation
          }
          result["metadata"] = metadata unless metadata.empty?
          result
        end

        def self.from_h(value)
          raise ArgumentError, "edge must be a Hash" unless value.is_a?(Hash)

          new(
            source: Reference.from_h(value.fetch("source") { value.fetch(:source) }),
            target: Reference.from_h(value.fetch("target") { value.fetch(:target) }),
            relation: value.fetch("relation") { value.fetch(:relation) },
            metadata: value["metadata"] || value[:metadata] || {}
          )
        end

        private
          def normalize_relation(value)
            normalized = value.to_s.strip
            raise ArgumentError, "relation must not be blank" if normalized.empty?

            normalized.freeze
          end
      end
    end
  end
end
