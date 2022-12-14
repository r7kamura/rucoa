# frozen_string_literal: true

module Rucoa
  module Handlers
    class TextDocumentHoverHandler < Base
      include HandlerConcerns::TextDocumentPositionParameters
      include HandlerConcerns::TextDocumentUriParameters

      def call
        respond(hover)
      end

      private

      # @return [String, nil]
      def contents
        @contents ||=
          case definition
          when Definitions::ClassDefinition, Definitions::ConstantDefinition, Definitions::ModuleDefinition
            [
              definition.qualified_name,
              definition.description
            ].compact.join("\n")
          when Definitions::MethodDefinition
            [
              definition.signatures.join("\n"),
              definition.description
            ].join("\n\n")
          end
      end

      # @return [Rucoa::Definitions::Base, nil]
      def definition
        return unless node

        @definition ||= NodeInspector.new(
          definition_store: definition_store,
          node: node
        ).definitions.first
      end

      # @return [Hash, nil]
      def hover
        return unless responsible?

        {
          contents: contents,
          range: range.to_vscode_range
        }
      end

      # @return [Rucoa::Range]
      def range
        Range.from_parser_range(node.location.expression)
      end

      # @return [Boolean]
      def responsible?
        configuration.enables_hover? &&
          !contents.nil?
      end
    end
  end
end
