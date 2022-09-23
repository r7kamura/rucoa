# frozen_string_literal: true

module Rucoa
  module Yard
    module DefinitionGenerators
      class AttributeReaderDefinitionGenerator < Base
        READER_METHOD_NAMES = ::Set[
          'attr_accessor',
          'attr_reader'
        ].freeze

        # @example returns method definition for attr_reader node
        #   definitions = Rucoa::Source.new(
        #     content: <<~RUBY,
        #       class Foo
        #         attr_reader :bar
        #       end
        #     RUBY
        #     uri: '/path/to/foo.rb'
        #   ).definitions
        #   expect(definitions[1]).to be_a(Rucoa::Definitions::MethodDefinition)
        # @example returns method definition for attr_accessor node
        #   definitions = Rucoa::Source.new(
        #     content: <<~RUBY,
        #       class Foo
        #         attr_accessor :bar
        #       end
        #     RUBY
        #     uri: '/path/to/foo.rb'
        #   ).definitions
        #   expect(definitions.map(&:fully_qualified_name)).to eq(
        #     %w[
        #       Foo
        #       Foo#bar
        #       Foo#bar=
        #     ]
        #   )
        def call
          return [] unless @node.is_a?(Nodes::SendNode) && READER_METHOD_NAMES.include?(@node.name)

          @node.arguments.map do |argument|
            Definitions::MethodDefinition.new(
              description: description,
              kind: :instance,
              location: Location.from_rucoa_node(@node),
              method_name: argument.value.to_s,
              namespace: @node.namespace,
              types: return_types.map do |type|
                Types::MethodType.new(
                  parameters_string: '', # TODO
                  return_type: type
                )
              end
            )
          end
        end
      end
    end
  end
end
