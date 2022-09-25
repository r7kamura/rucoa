# frozen_string_literal: true

module Rucoa
  module Yard
    module DefinitionGenerators
      class ClassDefinitionGenerator < ModuleDefinitionGenerator
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
        #   expect(definitions[0].included_module_unqualified_names.map(&:chained_name)).to eq(%w[Bar])
        # @example detects multi-arguments include
        #   definitions = Rucoa::Source.new(
        #     content: <<~RUBY,
        #       class Foo
        #         include Bar, Baz
        #       end
        #     RUBY
        #     uri: '/path/to/foo.rb'
        #   ).definitions
        #   expect(definitions[0].included_module_unqualified_names.map(&:chained_name)).to eq(%w[Bar Baz])
        # @example ignores non-simple include
        #   definitions = Rucoa::Source.new(
        #     content: <<~RUBY,
        #       class Foo
        #         include foo
        #       end
        #     RUBY
        #     uri: '/path/to/foo.rb'
        #   ).definitions
        #   expect(definitions[0].included_module_unqualified_names.map(&:chained_name)).to eq([])
        def call
          return [] unless @node.is_a?(Nodes::ClassNode)

          [
            Definitions::ClassDefinition.new(
              description: description,
              extended_module_unqualified_names: extended_module_unqualified_names,
              included_module_unqualified_names: included_module_unqualified_names,
              location: location,
              prepended_module_unqualified_names: prepended_module_unqualified_names,
              qualified_name: @node.qualified_name,
              super_class_unqualified_name: UnqualifiedName.new(
                chained_name: @node.super_class_chained_name,
                module_nesting: @node.module_nesting
              )
            )
          ]
        end
      end
    end
  end
end
