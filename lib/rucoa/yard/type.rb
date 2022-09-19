# frozen_string_literal: true

module Rucoa
  module Yard
    class Type
      # @param value [String]
      def initialize(value)
        @value = value
      end

      # @return [String]
      # @example scrubs "Array<String>" to "Array"
      #   yard_type = Rucoa::Yard::Type.new(
      #     'Array<String>'
      #   )
      #   expect(yard_type.to_rucoa_type).to eq('Array')
      # @example scrubs "Array(String, Integer)" to "Array"
      #   yard_type = Rucoa::Yard::Type.new(
      #     'Array(String, Integer)'
      #   )
      #   expect(yard_type.to_rucoa_type).to eq('Array')
      # @example scrubs "::Array" to "Array"
      #   yard_type = Rucoa::Yard::Type.new(
      #     '::Array'
      #   )
      #   expect(yard_type.to_rucoa_type).to eq('Array')
      # @example scrubs "Hash{Symbol => Object}" to "Hash"
      #   yard_type = Rucoa::Yard::Type.new(
      #     'Hash{Symbol => Object}'
      #   )
      #   expect(yard_type.to_rucoa_type).to eq('Hash')
      # @example scrubs "Array<Array<Integer>>" to "Array"
      #   yard_type = Rucoa::Yard::Type.new(
      #     'Array<Array<Integer>>'
      #   )
      #   expect(yard_type.to_rucoa_type).to eq('Array')
      def to_rucoa_type
        @value
          .delete_prefix('::')
          .gsub(/<.+>/, '')
          .gsub(/\{.+\}/, '')
          .gsub(/\(.+\)/, '')
      end
    end
  end
end
