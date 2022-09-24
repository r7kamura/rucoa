# frozen_string_literal: true

module Rucoa
  module Yard
    module DefinitionGenerators
      class ConstantAssignmentDefinitionGenerator < Base
        # @example returns constant definition for constant assignment node
        #   definitions = Rucoa::Source.new(
        #     content: <<~RUBY,
        #       Foo = 'foo'
        #     RUBY
        #     uri: '/path/to/foo.rb'
        #   ).definitions
        #   expect(definitions[0]).to be_a(Rucoa::Definitions::ConstantDefinition)
        def call
          return [] unless @node.is_a?(Nodes::CasgnNode)

          [
            Definitions::ConstantDefinition.new(
              description: description,
              fully_qualified_name: @node.fully_qualified_name,
              location: location
            )
          ]
        end
      end
    end
  end
end
