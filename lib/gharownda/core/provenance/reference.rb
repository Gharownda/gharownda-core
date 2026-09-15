# frozen_string_literal: true

module Gharownda
  module Core
    module Provenance
      class Reference
        attr_reader :type, :id, :metadata

        def initialize(type:, id:, metadata: {})
          @type = normalize_component(type, "type")
          @id = normalize_component(id, "id")
          raise ArgumentError, "metadata must be a Hash" unless metadata.is_a?(Hash)

          @metadata = metadata.each_with_object({}) { |(key, value), copy| copy[key.to_s] = value }.freeze
          freeze
        end

        def key
          [ type, id ].freeze
        end

        def ==(other)
          other.is_a?(Reference) && other.type == type && other.id == id
        end
        alias eql? ==

        def hash
          key.hash
        end

        def to_h
          result = { "type" => type, "id" => id }
          result["metadata"] = metadata unless metadata.empty?
          result
        end

        def self.from_h(value)
          raise ArgumentError, "reference must be a Hash" unless value.is_a?(Hash)

          new(
            type: value.fetch("type") { value.fetch(:type) },
            id: value.fetch("id") { value.fetch(:id) },
            metadata: value["metadata"] || value[:metadata] || {}
          )
        end

        private
          def normalize_component(value, name)
            normalized = value.to_s.strip
            raise ArgumentError, "#{name} must not be blank" if normalized.empty?

            normalized.freeze
          end
      end
    end
  end
end
