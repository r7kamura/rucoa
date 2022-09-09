# frozen_string_literal: true

require 'yard'

module Rucoa
  module DefinitionBuilders
    class YardMethodDefinitionBuilder
      class << self
        # @param code_object [YARD::CodeObjects::MethodObject]
        # @param path [String]
        # @return [Rucoa::Definitions::Base]
        def call(code_object:, path:)
          new(
            code_object: code_object,
            path: path
          ).call
        end
      end

      # @param code_object [YARD::CodeObjects::Base]
      # @param path [String]
      def initialize(code_object:, path:)
        @code_object = code_object
        @path = path
      end

      # @return [Rucoa::Definitions::Base]
      def call
        ::Rucoa::Definitions::MethodDefinition.new(
          description: description,
          kind: kind,
          method_name: method_name,
          namespace: namespace,
          source_path: @path,
          types: types
        )
      end

      private

      # @return [String]
      def description
        @code_object.docstring.to_s
      end

      # @return [Symbol]
      def kind
        if @code_object.scope == :instance
          :instance
        else
          :singleton
        end
      end

      # @return [String
      def method_name
        @code_object.name
      end

      # @return [String]
      def namespace
        @code_object.namespace.to_s
      end

      # @return [Array<Rucoa::Types::MethodType>]
      def types
        return_types.map do |return_type|
          ::Rucoa::Types::MethodType.new(
            parameters_string: '', # TODO
            return_type: return_type
          )
        end
      end

      # @return [Array<Rucoa::Definitions::MethodParameterDefinition>]
      def parameters
        parameter_tags.map do |parameter_tag|
          ::Rucoa::Definitions::MethodParameterDefinition.new(
            name: parameter_tag.name,
            types: parameter_tag.types
          )
        end
      end

      # @return [Array<YARD::Tags::Tag>]
      def parameter_tags
        @code_object.tags(:param) + @code_object.tags(:overload).flat_map do |overload_tag|
          overload_tag.tags(:param)
        end
      end

      # @return [Array<String>]
      def return_types
        return_tags.flat_map(&:types).map do |type|
          YardType.new(type).to_rucoa_type
        end
      end

      # @return [YARD::Tags::Tag]
      def return_tags
        @code_object.tags(:return) + @code_object.tags(:overload).flat_map do |overload_tag|
          overload_tag.tags(:return)
        end
      end

      class YardType
        # @param type [String]
        def initialize(type)
          @type = type
        end

        # @return [String]
        # @example scrubs "Array<String>" to "Array"
        #   yard_type = Rucoa::DefinitionBuilders::YardMethodDefinitionBuilder::YardType.new(
        #     'Array<String>'
        #   )
        #   expect(yard_type.to_rucoa_type).to eq('Array')
        # @example scrubs "Array(String, Integer)" to "Array"
        #   yard_type = Rucoa::DefinitionBuilders::YardMethodDefinitionBuilder::YardType.new(
        #     'Array(String, Integer)'
        #   )
        #   expect(yard_type.to_rucoa_type).to eq('Array')
        # @example scrubs "::Array" to "Array"
        #   yard_type = Rucoa::DefinitionBuilders::YardMethodDefinitionBuilder::YardType.new(
        #     '::Array'
        #   )
        #   expect(yard_type.to_rucoa_type).to eq('Array')
        # @example scrubs "Hash{Symbol => Object}" to "Hash"
        #   yard_type = Rucoa::DefinitionBuilders::YardMethodDefinitionBuilder::YardType.new(
        #     'Hash{Symbol => Object}'
        #   )
        #   expect(yard_type.to_rucoa_type).to eq('Hash')
        # @exampel scrubs "Array<Array<Integer>>" to "Array"
        #   yard_type = Rucoa::DefinitionBuilders::YardMethodDefinitionBuilder::YardType.new(
        #     'Array<Array<Integer>>'
        #   )
        #   expect(yard_type.to_rucoa_type).to eq('Array')
        def to_rucoa_type
          @type
            .delete_prefix('::')
            .gsub(/<.+>/, '')
            .gsub(/\{.+\}/, '')
            .gsub(/\(.+\)/, '')
        end
      end
    end
  end
end
