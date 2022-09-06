# frozen_string_literal: true

module Rucoa
  module Handlers
    class TextDocumentFormattingHandler < Base
      def call
        respond(edits)
      end

      private

      # @return [Array<Hash>]
      def edits
        return unless configuration.enables_formatting?
        return unless source

        FormattingProvider.call(
          source: source
        )
      end

      # @return [Rucoa::Source, nil]
      def source
        @source ||= source_store.get(uri)
      end

      # @return [String]
      def uri
        request.dig('params', 'textDocument', 'uri')
      end
    end
  end
end
