# frozen_string_literal: true

module Rucoa
  class Server
    # @return [Hash{String => Class}]
    METHOD_TO_HANDLER_MAP = {
      'initialize' => Handlers::InitializeHandler,
      'initialized' => Handlers::InitializedHandler,
      'textDocument/codeAction' => Handlers::TextDocumentCodeActionHandler,
      'textDocument/didChange' => Handlers::TextDocumentDidChangeHandler,
      'textDocument/didOpen' => Handlers::TextDocumentDidOpenHandler,
      'textDocument/documentSymbol' => Handlers::TextDocumentDocumentSymbolHandler,
      'textDocument/formatting' => Handlers::TextDocumentFormattingHandler,
      'textDocument/rangeFormatting' => Handlers::TextDocumentRangeFormattingHandler,
      'textDocument/selectionRange' => Handlers::TextDocumentSelectionRangeHandler,
      'textDocument/signatureHelp' => Handlers::TextDocumentSignatureHelpHandler,
      'workspace/didChangeConfiguration' => Handlers::WorkspaceDidChangeConfigurationHandler
    }.freeze
    private_constant :METHOD_TO_HANDLER_MAP

    # @return [Rucoa::Configuration]
    attr_reader :configuration

    # @return [Rucoa::DefinitionStore]
    attr_reader :definition_store

    # @return [Rucoa::SourceStore]
    attr_reader :source_store

    # @param input [IO]
    # @param output [IO]
    def initialize(input:, output:)
      @reader = MessageReader.new(input)
      @writer = MessageWriter.new(output)

      @client_response_handlers = {}
      @configuration = Configuration.new
      @server_request_id = 0
      @source_store = SourceStore.new

      @definition_store = DefinitionStore.new
      @definition_store.definitions += DefinitionArchiver.load
    end

    # @return [void]
    def start
      @reader.read do |request|
        handle(request)
      end
    end

    # @yieldparam response [Hash]
    # @param message [Hash]
    # @return [void]
    def write(message, &block)
      if block
        write_server_request(message, &block)
      else
        write_server_response(message)
      end
    end

    # @note This method is for testing.
    # @return [Array<Hash>]
    def responses
      io = @writer.io
      io.rewind
      MessageReader.new(io).read.to_a
    end

    private

    # @param request [Hash]
    # @return [void]
    def handle(request)
      if request['method']
        handle_client_request(request)
      elsif request['id']
        handle_client_response(request)
      end
    end

    # @param request [Hash]
    # @return [void]
    def handle_client_request(request)
      find_client_request_handler(request['method'])&.call(
        request: request,
        server: self
      )
    end

    # @param response [Hash]
    # @return [void]
    def handle_client_response(response)
      @client_response_handlers.delete(response['id'])&.call(response)
    end

    # @param request_method [String]
    # @return [Class, nil]
    def find_client_request_handler(request_method)
      METHOD_TO_HANDLER_MAP[request_method]
    end

    # @param message [Hash]
    # @return [void]
    def write_server_request(message, &block)
      @writer.write(
        message.merge(
          id: @server_request_id
        )
      )
      @client_response_handlers[@server_request_id] = block
      @server_request_id += 1
    end

    # @param message [Hash]
    # @return [void]
    def write_server_response(message)
      @writer.write(message)
    end
  end
end
