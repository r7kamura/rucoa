# frozen_string_literal: true

module Rucoa
  module Handlers
    class TextDocumentDefinitionHandler < Base
      def call
        respond(location)
      end

      private

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

      # @return [Rucoa::Position]
      def position
        Position.from_vscode_position(
          request.dig('params', 'position')
        )
      end

      # @return [String]
      def uri
        request.dig('params', 'textDocument', 'uri')
      end

      # @return [Rucoa::Source, nil]
      def source
        source_store.get(uri)
      end

      # @return [Rucoa::Nodes::Base]
      def node
        source&.node_at(position)
      end

      # @return [Rucoa::Definitions::Base, nil]
      def definition
        @definition ||= NodeInspector.new(
          definition_store: definition_store,
          node: node
        ).definitions.first
      end
    end
  end
end
