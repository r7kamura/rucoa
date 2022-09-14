# frozen_string_literal: true

module Rucoa
  module Handlers
    class TextDocumentDidCloseHandler < Base
      include HandlerConcerns::DiagnosticsPublishable

      def call
        clear_diagnostics_on(uri)
      end

      private

      # @return [String]
      def uri
        request.dig('params', 'textDocument', 'uri')
      end
    end
  end
end
