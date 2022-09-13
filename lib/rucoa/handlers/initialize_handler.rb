# frozen_string_literal: true

module Rucoa
  module Handlers
    class InitializeHandler < Base
      def call
        respond(
          capabilities: {
            codeActionProvider: true,
            completionProvider: {
              resolveProvider: true,
              triggerCharacters: %w[
                .
              ]
            },
            documentFormattingProvider: true,
            documentRangeFormattingProvider: true,
            documentSymbolProvider: true,
            hoverProvider: true,
            selectionRangeProvider: true,
            signatureHelpProvider: {
              triggerCharacters: %w[
                (
                ,
              ]
            },
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
