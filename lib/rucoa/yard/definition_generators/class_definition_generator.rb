# frozen_string_literal: true

module Rucoa
  module Yard
    module DefinitionGenerators
      class ClassDefinitionGenerator < Base
        # @example returns class definition for class node
        #   definitions = Rucoa::Source.new(
        #     content: <<~RUBY,
        #       class Foo
        #       end
        #     RUBY
        #     uri: '/path/to/foo.rb'
        #   ).definitions
        #   expect(definitions[0]).to be_a(Rucoa::Definitions::ClassDefinition)
        def call
          return [] unless @node.is_a?(Nodes::ClassNode)

          included_module_chained_names = @node.body_children.filter_map do |child|
            next unless child.is_a?(Nodes::SendNode)
            next unless child.name == 'include'

            includee_node = child.arguments.first
            next unless includee_node.is_a?(Nodes::ConstNode)

            includee_node.chained_name
          end

          [
            Definitions::ClassDefinition.new(
              description: description,
              fully_qualified_name: @node.fully_qualified_name,
              included_module_chained_names: included_module_chained_names,
              location: Location.from_rucoa_node(@node),
              module_nesting: @node.module_nesting,
              super_class_chained_name: @node.super_class_chained_name
            )
          ]
        end
      end
    end
  end
end
