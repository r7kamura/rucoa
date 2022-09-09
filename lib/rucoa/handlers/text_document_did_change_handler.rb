# frozen_string_literal: true

module Rucoa
  module Handlers
    class TextDocumentDidChangeHandler < TextDocumentDidOpenHandler
      # @return [String]
      def text
        request.dig('params', 'contentChanges')[0]['text']
      end
    end
  end
end
