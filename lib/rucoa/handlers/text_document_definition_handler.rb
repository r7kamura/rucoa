# frozen_string_literal: true

module Rucoa
  module Handlers
    class TextDocumentDefinitionHandler < Base
      include HandlerConcerns::TextDocumentPositionParameters
      include HandlerConcerns::TextDocumentUriParameters

      def call
        respond(location)
      end

      private

      # @return [Rucoa::Definitions::Base, nil]
      def definition
        @definition ||= NodeInspector.new(
          definition_store: definition_store,
          node: node
        ).definitions.first
      end

      # @return [Hash, nil]
      def location
        return unless reponsible?

        {
          range: definition.location.range.to_vscode_range,
          uri: definition.location.uri
        }
      end

      # @return [Boolean]
      def reponsible?
        configuration.enables_definition? &&
          !definition&.location.nil?
      end
    end
  end
end
