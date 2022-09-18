# frozen_string_literal: true

module Rucoa
  module Handlers
    class TextDocumentDidOpenHandler < Base
      include HandlerConcerns::DiagnosticsPublishable

      def call
        source_store.update(source)
        definition_store.update_from(source)
        publish_diagnostics_on(uri)
      end

      private

      # @return [Rucoa::Source]
      def source
        @source ||= Source.new(
          content: text,
          uri: uri
        )
      end

      # @return [String]
      def text
        request.dig('params', 'textDocument', 'text')
      end

      # @return [String]
      def uri
        @uri ||= request.dig('params', 'textDocument', 'uri')
      end
    end
  end
end
