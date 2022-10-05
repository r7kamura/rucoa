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
              extended_module_unqualified_names: extended_module_unqualified_names,
              included_module_unqualified_names: included_module_unqualified_names,
              location: location,
              prepended_module_unqualified_names: prepended_module_unqualified_names,
              qualified_name: @node.qualified_name
            )
          ]
        end

        private

        # @return [Array<Rucoa::UnqualifiedName>]
        def extended_module_unqualified_names
          unqualified_names_for('extend')
        end

        # @return [Array<Rucoa::UnqualifiedName>]
        def included_module_unqualified_names
          unqualified_names_for('include')
        end

        # @return [Array<Rucoa::UnqualifiedName>]
        def prepended_module_unqualified_names
          unqualified_names_for('prepend')
        end

        # @param method_name [String]
        # @return [Array<Rucoa::UnqualifiedName>]
        def unqualified_names_for(method_name)
          @node.body_children.flat_map do |child|
            next [] unless child.is_a?(Nodes::SendNode)
            next [] unless child.name == method_name

            child.arguments.reverse.filter_map do |argument|
              next unless argument.is_a?(Nodes::ConstNode)

              UnqualifiedName.new(
                chained_name: argument.chained_name,
                module_nesting: @node.module_nesting
              )
            end
          end
        end
      end
    end
  end
end
