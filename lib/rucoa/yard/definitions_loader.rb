# frozen_string_literal: true

require 'logger'
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

        # @param comment [String]
        # @return [YARD::DocstringParser]
        def parse_yard_comment(comment)
          ::YARD::Logger.instance.enter_level(::Logger::FATAL) do
            ::YARD::Docstring.parser.parse(
              comment,
              ::YARD::CodeObjects::Base.new(:root, 'stub')
            )
          end
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
          *@root_node.descendants
        ].filter_map do |node|
          comment = comment_for(node)
          case node
          when Nodes::ClassNode
            Definitions::ClassDefinition.new(
              fully_qualified_name: node.fully_qualified_name,
              module_nesting: node.module_nesting,
              source_path: @root_node.location.expression.source_buffer.name,
              super_class_chained_name: node.super_class_chained_name
            )
          when Nodes::ModuleNode
            Definitions::ModuleDefinition.new(
              fully_qualified_name: node.fully_qualified_name,
              source_path: @root_node.location.expression.source_buffer.name
            )
          when Nodes::DefNode, Nodes::DefsNode
            docstring_parser = self.class.parse_yard_comment(comment)
            return_types = docstring_parser.tags.select do |tag|
              tag.tag_name == 'return'
            end.flat_map(&:types).compact.map do |yard_type|
              Type.new(yard_type).to_rucoa_type
            end
            return_types = ['Object'] if return_types.empty?
            Definitions::MethodDefinition.new(
              description: docstring_parser.to_docstring.to_s,
              kind: node.singleton? ? :singleton : :instance,
              method_name: node.name,
              namespace: node.namespace,
              source_path: @root_node.location.expression.source_buffer.name,
              types: return_types.map do |type|
                Types::MethodType.new(
                  parameters_string: '', # TODO
                  return_type: type
                )
              end
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
