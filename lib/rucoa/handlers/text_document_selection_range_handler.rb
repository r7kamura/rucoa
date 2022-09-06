# frozen_string_literal: true

module Rucoa
  module Handlers
    class TextDocumentSelectionRangeHandler < Base
      def call
        return unless configuration.enables_selection_range?

        source = source_store.get(
          request.dig('params', 'textDocument', 'uri')
        )
        return unless source

        respond(
          request.dig('params', 'positions').filter_map do |position|
            SelectionRangeProvider.call(
              position: Position.from_vscode_position(position),
              source: source
            )
          end
        )
      end
    end
  end
end
