# frozen_string_literal: true

module Rucoa
  module Handlers
    class TextDocumentSelectionRangeHandler < Base
      def call
        return unless respondable?

        respond(
          positions.filter_map do |position|
            SelectionRangeProvider.call(
              position: position,
              source: source
            )
          end
        )
      end

      private

      # @return [Boolean]
      def respondable?
        configuration.enables_selection_range? &&
          source
      end

      # @return [Rucoa::Source]
      def source
        @source ||= source_store.get(uri)
      end

      # @return [Array<Rucoa::Position>]
      def positions
        request.dig('params', 'positions').map do |position|
          Position.from_vscode_position(position)
        end
      end

      # @return [String]
      def uri
        request.dig('params', 'textDocument', 'uri')
      end
    end
  end
end
