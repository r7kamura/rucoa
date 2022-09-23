# frozen_string_literal: true

module Rucoa
  module Yard
    module DefinitionGenerators
      class ModuleDefinitionGenerator < Base
        # @example returns module definition for module node
        #   definitions = Rucoa::Source.new(
        #     content: <<~RUBY,
        #       module Foo
        #       end
        #     RUBY
        #     uri: '/path/to/foo.rb'
        #   ).definitions
        #   expect(definitions[0]).to be_a(Rucoa::Definitions::ModuleDefinition)
        def call
          return [] unless @node.is_a?(Nodes::ModuleNode)

          [
            Definitions::ModuleDefinition.new(
              description: description,
              fully_qualified_name: @node.fully_qualified_name,
              location: Location.from_rucoa_node(@node)
            )
          ]
        end
      end
    end
  end
end
