# frozen_string_literal: true

require 'logger'
require 'set'
require 'yard'

module Rucoa
  module Yard
    class DefinitionsLoader
      class << self
        # @param associations [Hash]
        # @param root_node [Rucoa::Nodes::Base]
        def call(
          associations:,
          root_node:
        )
          new(
            associations: associations,
            root_node: root_node
          ).call
        end
      end

      # @param associations [Hash]
      # @param root_node [Rucoa::Nodes::Base]
      def initialize(
        associations:,
        root_node:
      )
        @associations = associations
        @root_node = root_node
      end

      # @return [Array<Rucoa::Definition::Base>]
      def call
        [
          @root_node,
          *@root_node.descendant_nodes
        ].flat_map do |node|
          [
            DefinitionGenerators::ClassDefinitionGenerator,
            DefinitionGenerators::ConstantAssignmentDefinitionGenerator,
            DefinitionGenerators::MethodDefinitionGenerator,
            DefinitionGenerators::ModuleDefinitionGenerator,
            DefinitionGenerators::AttributeReaderDefinitionGenerator,
            DefinitionGenerators::AttributeWriterDefinitionGenerator
          ].flat_map do |generator|
            generator.call(
              comment: comment_for(node),
              node: node
            )
          end
        end
      end

      # @return [String]
      def comment_for(node)
        @associations[node.location].map do |parser_comment|
          parser_comment.text.gsub(/^#\s*/m, '')
        end.join("\n")
      end
    end
  end
end
