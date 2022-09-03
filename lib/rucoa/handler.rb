# frozen_string_literal: true

module Rucoa
  class Handler
    def initialize
      @document_store = DocumentStore.new
    end

    # @param request [Hash]
    # @return [nil] If no response is provided by handler.
    # @return [#to_hash] If response is provided by handler.
    def call(request)
      case request['method']
      when 'initialize'
        on_initialize(request)
      when 'textDocument/didChange'
        on_text_document_did_change(request)
      when 'textDocument/didOpen'
        on_text_document_did_open(request)
      when 'textDocument/selectionRange'
        on_text_document_selection_range(request)
      end
    end

    private

    # @param _request [Hash]
    # @return [Hash]
    def on_initialize(_request)
      {
        capabilities: {
          textDocumentSync: {
            change: 1, # Full
            openClose: true
          },
          selectionRangeProvider: true
        }
      }
    end

    # @param request [Hash]
    # @return [nil]
    def on_text_document_did_change(request)
      @document_store.set(
        request.dig('params', 'textDocument', 'uri'),
        request.dig('params', 'contentChanges')[0]['text']
      )
      nil
    end

    # @param request [Hash]
    # @return [nil]
    def on_text_document_did_open(request)
      @document_store.set(
        request.dig('params', 'textDocument', 'uri'),
        request.dig('params', 'textDocument', 'text')
      )
      nil
    end

    # @param request [Hash]
    # @return [Array<Hash>, nil]
    def on_text_document_selection_range(request)
      text = @document_store.get(
        request.dig('params', 'textDocument', 'uri')
      )
      return unless text

      request.dig('params', 'positions').filter_map do |position|
        SelectionRangeProvider.call(
          position: Position.from_vscode_position(position),
          text: text
        )
      end
    end
  end
end
