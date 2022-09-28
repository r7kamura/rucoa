# frozen_string_literal: true

module Rucoa
  module Handlers
    class TextDocumentDidCloseHandler < Base
      include HandlerConcerns::DiagnosticsPublishable
      include HandlerConcerns::TextDocumentUriParameters

      def call
        clear_diagnostics_on(parameter_uri)
      end
    end
  end
end
