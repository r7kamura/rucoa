# frozen_string_literal: true

module Rucoa
  module Handlers
    class TextDocumentHoverHandler < Base
      def call
        respond(hover)
      end

      private

      # @return [Hash, nil]
      def hover
        return unless responsible?

        {
          contents: contents,
          range: range.to_vscode_range
        }
      end

      # @return [Boolean]
      def responsible?
        configuration.enables_hover? &&
          !contents.nil?
      end

      # @return [String, nil]
      def contents
        @contents ||=
          case definition
          when Definitions::ClassDefinition, Definitions::ModuleDefinition
            [
              definition.fully_qualified_name,
              definition.description
            ].compact.join("\n")
          when Definitions::MethodDefinition
            [
              definition.signatures.join("\n"),
              definition.description
            ].join("\n\n")
          end
      end

      # @return [Rucoa::Range]
      def range
        Range.from_parser_range(node.location.expression)
      end

      # @return [Rucoa::Nodes::Base, nil]
      def node
        @node ||= source&.node_at(position)
      end

      # @return [Rucoa::Source, nil]
      def source
        @source ||= source_store.get(uri)
      end

      # @return [String]
      def uri
        request.dig('params', 'textDocument', 'uri')
      end

      # @return [Rucoa::Position]
      def position
        Position.from_vscode_position(
          request.dig('params', 'position')
        )
      end

      # @return [Rucoa::Definitions::Base, nil]
      def definition
        return unless node

        @definition ||= NodeInspector.new(
          definition_store: definition_store,
          node: node
        ).definitions.first
      end
    end
  end
end
