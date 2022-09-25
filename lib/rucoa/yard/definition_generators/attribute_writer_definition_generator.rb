# frozen_string_literal: true

module Rucoa
  module Yard
    module DefinitionGenerators
      class AttributeWriterDefinitionGenerator < Base
        WRITER_METHOD_NAMES = ::Set[
          'attr_accessor',
          'attr_writer'
        ].freeze

        # @example returns method definition for attr_writer node
        #   definitions = Rucoa::Source.new(
        #     content: <<~RUBY,
        #       class Foo
        #         attr_writer :bar
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
        #   expect(definitions.map(&:qualified_name)).to eq(
        #     %w[
        #       Foo
        #       Foo#bar
        #       Foo#bar=
        #     ]
        #   )
        # @example ignores unrecognizable attributes
        #   definitions = Rucoa::Source.new(
        #     content: <<~RUBY,
        #       class Foo
        #         attr_writer foo
        #       end
        #     RUBY
        #     uri: '/path/to/foo.rb'
        #   ).definitions
        #   expect(definitions.map(&:qualified_name)).to eq(
        #     %w[
        #       Foo
        #     ]
        #   )
        def call
          return [] unless @node.is_a?(Nodes::SendNode) && WRITER_METHOD_NAMES.include?(@node.name)

          @node.arguments.filter_map do |argument|
            next unless argument.respond_to?(:value)

            Definitions::MethodDefinition.new(
              description: description,
              kind: :instance,
              location: location,
              method_name: "#{argument.value}=",
              namespace: @node.namespace,
              types: return_types.map do |type|
                Types::MethodType.new(
                  parameters_string: 'value', # TODO
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
