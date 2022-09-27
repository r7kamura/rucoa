# frozen_string_literal: true

module Rucoa
  module Handlers
    class TextDocumentSignatureHelpHandler < Base
      def call
        respond(signature_help)
      end

      private

      # @return [Array<Rucoa::Definitions::MethodDefinition>]
      def method_definitions
        NodeInspector.new(
          definition_store: definition_store,
          node: node
        ).method_definitions
      end

      # @return [Rucoa::Nodes::Base, nil]
      def node
        @node ||= source.node_at(position)
      end

      # @return [Rucoa::Position]
      def position
        Position.from_vscode_position(
          request.dig('params', 'position')
        )
      end

      # @return [Boolean]
      def responsible?
        configuration.enables_signature_help? &&
          node.is_a?(Nodes::SendNode)
      end

      # @return [Hash]
      def signature_help
        return unless responsible?

        {
          signatures: signature_informations
        }
      end

      # @return [Array<Hash>]
      def signature_informations
        method_definitions.map do |method_definition|
          {
            documentation: method_definition.description,
            label: method_definition.signatures.join("\n")
          }
        end
      end

      # @return [Rucoa::Source]
      def source
        source_store.get(uri)
      end

      # @return [String]
      def uri
        request.dig('params', 'textDocument', 'uri')
      end
    end
  end
end
