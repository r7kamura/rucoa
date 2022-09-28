# frozen_string_literal: true

module Rucoa
  module Handlers
    class TextDocumentDidOpenHandler < Base
      include HandlerConcerns::DiagnosticsPublishable
      include HandlerConcerns::TextDocumentUriParameters

      def call
        source_store.update(source)
        definition_store.update_from(source)
        publish_diagnostics_on(parameter_uri)
      end

      private

      # @return [Rucoa::Source]
      def source
        @source ||= Source.new(
          content: text,
          uri: parameter_uri
        )
      end

      # @return [String]
      def text
        request.dig('params', 'textDocument', 'text')
      end
    end
  end
end
