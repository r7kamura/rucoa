# frozen_string_literal: true

module Rucoa
  module Handlers
    class TextDocumentSignatureHelpHandler < Base
      include HandlerConcerns::TextDocumentPositionParameters
      include HandlerConcerns::TextDocumentUriParameters

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
    end
  end
end
