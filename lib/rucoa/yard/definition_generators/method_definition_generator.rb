# frozen_string_literal: true

module Rucoa
  module Yard
    module DefinitionGenerators
      class MethodDefinitionGenerator < Base
        # @example returns method definition for def node
        #   definitions = Rucoa::Source.new(
        #     content: <<~RUBY,
        #       def foo
        #       end
        #     RUBY
        #     uri: '/path/to/foo.rb'
        #   ).definitions
        #   expect(definitions[0]).to be_a(Rucoa::Definitions::MethodDefinition)
        # @example returns method definition for defs node
        #   definitions = Rucoa::Source.new(
        #     content: <<~RUBY,
        #       def self.foo
        #       end
        #     RUBY
        #     uri: '/path/to/foo.rb'
        #   ).definitions
        #   expect(definitions[0]).to be_a(Rucoa::Definitions::MethodDefinition)
        # @example returns method definition for another style of singleton def node
        #   definitions = Rucoa::Source.new(
        #     content: <<~RUBY,
        #       class Foo
        #         class << self
        #           def bar
        #           end
        #         end
        #       end
        #     RUBY
        #     uri: '/path/to/foo.rb'
        #   ).definitions
        #   expect(definitions[1].qualified_name).to eq('Foo.bar')
        def call
          return [] unless @node.is_a?(Nodes::DefNode)

          [
            Definitions::MethodDefinition.new(
              description: description,
              kind: @node.singleton? ? :singleton : :instance,
              location: location,
              method_name: @node.name,
              namespace: @node.namespace,
              types: return_types.map do |type|
                Types::MethodType.new(
                  parameters_string: '', # TODO
                  return_type: type
                )
              end
            )
          ]
        end
      end
    end
  end
end
