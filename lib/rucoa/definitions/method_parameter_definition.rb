# frozen_string_literal: true

module Rucoa
  module Definitions
    # Represents method parameter definition.
    class MethodParameterDefinition < Base
      # @return [String]
      attr_reader :name

      # @return [Array<String>]
      attr_reader :types

      # @param name [String]
      # @param types [Array<String>]
      def initialize(name:, types:)
        super()
        @name = name
        @types = types
      end

      # @return [Hash{Symbol => Object}]
      def to_hash
        {
          name: name,
          types: types
        }
      end
    end
  end
end
