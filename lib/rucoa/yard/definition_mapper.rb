# frozen_string_literal: true

require 'yard'

module Rucoa
  module Yard
    class DefinitionMapper
      class << self
        # @param code_object [YARD::CodeObjects::Base]
        # @param path [String] This must be passed if the path is not available from code object.
        # @return [Rucoa::Definitions::Base, nil]
        def call(code_object, path: code_object.file)
          new(code_object, path: path).call
        end
      end

      # @param code_object [YARD::CodeObjects::Base]
      # @param path [String]
      def initialize(code_object, path:)
        @code_object = code_object
        @path = path
      end

      # @return [Rucoa::Definitions::Base, nil]
      def call
        return unless @code_object.is_a?(::YARD::CodeObjects::MethodObject)

        Definitions::MethodDefinition.new(
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
            parameters_string: parameters_string,
            return_type: return_type
          )
        end
      end

      # @return [String]
      # @example
      #   definitions = Rucoa::Yard::DefinitionsLoader.load_string(
      #     content: <<~RUBY,
      #       class Foo
      #         def bar(
      #           argument1,
      #           argument2 = nil,
      #           *arguments,
      #           keyword1:,
      #           keyword2: nil,
      #           **keywords,
      #           &block
      #         )
      #         end
      #       end
      #     RUBY
      #     path: '/path/to/foo.rb'
      #   )
      #   expect(definitions.first.signatures).to eq(
      #     [
      #       'Foo#bar(argument1, argument2 = nil, *arguments, keyword1:, keyword2: nil, **keywords, &block) -> Object'
      #     ]
      #   )
      def parameters_string
        @code_object.parameters.map do |parameter_name, default_value|
          default_value_part =
            if default_value.nil?
              nil
            elsif parameter_name.end_with?(':')
              " #{default_value}"
            else
              " = #{default_value}"
            end
          [
            parameter_name,
            default_value_part
          ].join
        end.join(', ')
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
      # @return [String]
      # @example returns return type annotated by YARD @return tags
      #   definitions = Rucoa::Yard::DefinitionsLoader.load_string(
      #     content: <<~RUBY,
      #       # @return [String]
      #       def foo
      #         'foo'
      #       end
      #     RUBY
      #     path: '/path/to/foo.rb'
      #   )
      #   expect(definitions.first.return_types).to eq(
      #     %w[
      #       String
      #     ]
      #   )
      # @example ignores empty @return tags
      #   definitions = Rucoa::Yard::DefinitionsLoader.load_string(
      #     content: <<~RUBY,
      #       # @return []
      #       def foo
      #         'foo'
      #       end
      #     RUBY
      #     path: '/path/to/foo.rb'
      #   )
      #   expect(definitions.first.return_types).to eq([])
      def return_types
        return %w[Object] if return_tags.empty?

        return_tags.flat_map(&:types).compact.map do |type|
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
        #   yard_type = Rucoa::Yard::DefinitionMapper::YardType.new(
        #     'Array<String>'
        #   )
        #   expect(yard_type.to_rucoa_type).to eq('Array')
        # @example scrubs "Array(String, Integer)" to "Array"
        #   yard_type = Rucoa::Yard::DefinitionMapper::YardType.new(
        #     'Array(String, Integer)'
        #   )
        #   expect(yard_type.to_rucoa_type).to eq('Array')
        # @example scrubs "::Array" to "Array"
        #   yard_type = Rucoa::Yard::DefinitionMapper::YardType.new(
        #     '::Array'
        #   )
        #   expect(yard_type.to_rucoa_type).to eq('Array')
        # @example scrubs "Hash{Symbol => Object}" to "Hash"
        #   yard_type = Rucoa::Yard::DefinitionMapper::YardType.new(
        #     'Hash{Symbol => Object}'
        #   )
        #   expect(yard_type.to_rucoa_type).to eq('Hash')
        # @example scrubs "Array<Array<Integer>>" to "Array"
        #   yard_type = Rucoa::Yard::DefinitionMapper::YardType.new(
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
