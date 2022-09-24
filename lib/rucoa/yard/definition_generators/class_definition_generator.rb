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
              included_module_chained_names: included_module_chained_names,
              location: location,
              module_nesting: @node.module_nesting,
              prepended_module_chained_names: prepended_module_chained_names,
              qualified_name: @node.qualified_name,
              super_class_chained_name: @node.super_class_chained_name
            )
          ]
        end

        private

        # @return [Array<String>]
        def included_module_chained_names
          chained_names_for('include')
        end

        # @return [Array<String>]
        def prepended_module_chained_names
          chained_names_for('prepend')
        end

        # @param method_name [String]
        # @return [Array<String>]
        def chained_names_for(method_name)
          @node.body_children.flat_map do |child|
            next [] unless child.is_a?(Nodes::SendNode)
            next [] unless child.name == method_name

            child.arguments.filter_map do |argument|
              next unless argument.is_a?(Nodes::ConstNode)

              argument.chained_name
            end
          end
        end
      end
    end
  end
end
