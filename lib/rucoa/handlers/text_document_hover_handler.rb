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
          !source.nil? &&
          !node.nil? &&
          !method_definitions.empty?
      end

      # @return [String, nil]
      def contents
        method_definition = method_definitions.first
        [
          method_definition.signatures.join("\n"),
          method_definition.description
        ].join("\n\n")
      end

      # @return [Rucoa::Range]
      def range
        Range.from_parser_range(node.location.expression)
      end

      # @return [Rucoa::Nodes::Base, nil]
      def node
        @node ||= source.node_at(position)
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

      # @return [Array<Rucoa::Definitions::MethodDefinition>]
      def method_definitions
        @method_definitions ||= NodeInspector.new(
          definition_store: definition_store,
          node: node
        ).method_definitions
      end
    end
  end
end
