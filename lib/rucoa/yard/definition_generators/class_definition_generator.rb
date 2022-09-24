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
        # @example detects single-argument include
        #   definitions = Rucoa::Source.new(
        #     content: <<~RUBY,
        #       class Foo
        #         include Bar
        #       end
        #     RUBY
        #     uri: '/path/to/foo.rb'
        #   ).definitions
        #   expect(definitions[0].included_module_chained_names).to eq(['Bar'])
        # @example detects multi-arguments include
        #   definitions = Rucoa::Source.new(
        #     content: <<~RUBY,
        #       class Foo
        #         include Bar, Baz
        #       end
        #     RUBY
        #     uri: '/path/to/foo.rb'
        #   ).definitions
        #   expect(definitions[0].included_module_chained_names).to eq(['Bar', 'Baz'])
        # @example ignores non-simple include
        #   definitions = Rucoa::Source.new(
        #     content: <<~RUBY,
        #       class Foo
        #         include foo
        #       end
        #     RUBY
        #     uri: '/path/to/foo.rb'
        #   ).definitions
        #   expect(definitions[0].included_module_chained_names).to eq([])
        def call
          return [] unless @node.is_a?(Nodes::ClassNode)

          [
            Definitions::ClassDefinition.new(
              description: description,
              fully_qualified_name: @node.fully_qualified_name,
              included_module_chained_names: included_module_chained_names,
              location: location,
              module_nesting: @node.module_nesting,
              super_class_chained_name: @node.super_class_chained_name
            )
          ]
        end

        private

        # @return [Array<String>]
        def included_module_chained_names
          @node.body_children.flat_map do |child|
            next [] unless child.is_a?(Nodes::SendNode)
            next [] unless child.name == 'include'

            child.arguments.filter_map do |includee|
              next unless includee.is_a?(Nodes::ConstNode)

              includee.chained_name
            end
          end
        end
      end
    end
  end
end
