# frozen_string_literal: true

module Rucoa
  module Handlers
    class InitializeHandler < Base
      def call
        respond(
          capabilities: {
            codeActionProvider: true,
            documentFormattingProvider: true,
            documentRangeFormattingProvider: true,
            documentSymbolProvider: true,
            selectionRangeProvider: true,
            textDocumentSync: {
              change: 1, # Full
              openClose: true
            }
          }
        )
      end
    end
  end
end
