# frozen_string_literal: true

module Rucoa
  module Handlers
    class TextDocumentRangeFormattingHandler < Base
      def call
        return unless configuration.enables_formatting?

        uri = request.dig('params', 'textDocument', 'uri')
        source = source_store.get(uri)
        return unless source

        respond(
          RangeFormattingProvider.call(
            range: Range.from_vscode_range(
              request.dig('params', 'range')
            ),
            source: source
          )
        )
      end
    end
  end
end
