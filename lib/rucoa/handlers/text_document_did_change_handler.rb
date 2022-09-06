# frozen_string_literal: true

module Rucoa
  module Handlers
    class TextDocumentDidChangeHandler < Base
      include HandlerConcerns::DiagnosticsPublishable

      def call
        update_source
        publish_diagnostics_on(uri)
      end

      private

      # @return [void]
      def update_source
        source_store.set(uri, text)
      end

      # @return [String]
      def text
        request.dig('params', 'contentChanges')[0]['text']
      end

      # @return [String]
      def uri
        @uri ||= request.dig('params', 'textDocument', 'uri')
      end
    end
  end
end
