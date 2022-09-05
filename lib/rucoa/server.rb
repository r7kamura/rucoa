# frozen_string_literal: true

module Rucoa
  class Server
    # @param reader [IO]
    # @param writer [IO]
    def initialize(reader:, writer:)
      @reader = MessageReader.new(reader)
      @writer = MessageWriter.new(writer)
      @source_store = SourceStore.new
    end

    # @return [void]
    def start
      read do |request|
        result = handle(request)
        if result
          write(
            request: request,
            result: result
          )
        end
      end
    end

    private

    # @param request [Hash]
    # @return [Object]
    def handle(request)
      case request['method']
      when 'initialize'
        on_initialize(request)
      when 'textDocument/codeAction'
        on_text_document_code_action(request)
      when 'textDocument/didChange'
        on_text_document_did_change(request)
      when 'textDocument/didOpen'
        on_text_document_did_open(request)
      when 'textDocument/formatting'
        on_text_document_formatting(request)
      when 'textDocument/rangeFormatting'
        on_text_document_range_formatting(request)
      when 'textDocument/selectionRange'
        on_text_document_selection_range(request)
      end
    end

    # @yieldparam request [Hash]
    # @return [void]
    def read(&block)
      @reader.read(&block)
    end

    # @param request [Hash]
    # @param result [Object]
    # @return [void]
    def write(request:, result:)
      @writer.write(
        {
          id: request['id'],
          result: result
        }
      )
    end

    # @param uri [String]
    # @return [void]
    def investigate_diagnostics(uri:)
      @writer.write(
        method: 'textDocument/publishDiagnostics',
        params: {
          diagnostics: DiagnosticProvider.call(
            source: @source_store.get(uri),
            uri: uri
          ),
          uri: uri
        }
      )
    end

    # @param _request [Hash]
    # @return [Hash]
    def on_initialize(_request)
      {
        capabilities: {
          codeActionProvider: true,
          documentFormattingProvider: true,
          documentRangeFormattingProvider: true,
          selectionRangeProvider: true,
          textDocumentSync: {
            change: 1, # Full
            openClose: true
          }
        }
      }
    end

    # @param request [Hash]
    # @return [Array<Hash>, nil]
    def on_text_document_code_action(request)
      diagnostics = request.dig('params', 'context', 'diagnostics')
      return unless diagnostics

      CodeActionProvider.call(
        diagnostics: diagnostics
      )
    end

    # @param request [Hash]
    # @return [nil]
    def on_text_document_did_change(request)
      uri = request.dig('params', 'textDocument', 'uri')
      @source_store.set(
        uri,
        request.dig('params', 'contentChanges')[0]['text']
      )
      investigate_diagnostics(uri: uri)
      nil
    end

    # @param request [Hash]
    # @return [nil]
    def on_text_document_did_open(request)
      uri = request.dig('params', 'textDocument', 'uri')
      @source_store.set(
        uri,
        request.dig('params', 'textDocument', 'text')
      )
      investigate_diagnostics(uri: uri)
      nil
    end

    # @param request [Hash]
    # @return [Array<Hash>, nil]
    def on_text_document_formatting(request)
      uri = request.dig('params', 'textDocument', 'uri')
      source = @source_store.get(uri)
      return unless source

      FormattingProvider.call(
        source: source
      )
    end

    # @param request [Hash]
    # @return [Array<Hash>, nil]
    def on_text_document_range_formatting(request)
      uri = request.dig('params', 'textDocument', 'uri')
      source = @source_store.get(uri)
      return unless source

      RangeFormattingProvider.call(
        range: Range.from_vscode_range(
          request.dig('params', 'range')
        ),
        source: source
      )
    end

    # @param request [Hash]
    # @return [Array<Hash>, nil]
    def on_text_document_selection_range(request)
      source = @source_store.get(
        request.dig('params', 'textDocument', 'uri')
      )
      return unless source

      request.dig('params', 'positions').filter_map do |position|
        SelectionRangeProvider.call(
          position: Position.from_vscode_position(position),
          source: source
        )
      end
    end
  end
end
