# frozen_string_literal: true

require 'logger'
require 'stringio'

module Rucoa
  class Server
    # @return [Hash{String => Class}]
    METHOD_TO_HANDLER_MAP = {
      'exit' => Handlers::ExitHandler,
      'initialize' => Handlers::InitializeHandler,
      'initialized' => Handlers::InitializedHandler,
      'shutdown' => Handlers::ShutdownHandler,
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

    # @return [Boolean]
    attr_accessor :shutting_down

    # @return [Rucoa::Configuration]
    attr_reader :configuration

    # @return [Rucoa::DefinitionStore]
    attr_reader :definition_store

    # @return [Rucoa::SourceStore]
    attr_reader :source_store

    # @param io_log [IO]
    # @param io_in [IO]
    # @param io_out [IO]
    def initialize(
      io_log: ::StringIO.new,
      io_in: ::StringIO.new,
      io_out: ::StringIO.new
    )
      @logger = ::Logger.new(io_log)
      @logger.level = ::Logger::DEBUG
      @reader = MessageReader.new(io_in)
      @writer = MessageWriter.new(io_out)

      @client_response_handlers = {}
      @configuration = Configuration.new
      @server_request_id = 0
      @shutting_down = false
      @source_store = SourceStore.new

      @definition_store = DefinitionStore.new
      @definition_store.definitions += DefinitionArchiver.load
    end

    # @return [void]
    def start
      @reader.read do |message|
        debug do
          {
            kind: :read,
            message: message
          }
        end
        handle(message)
      end
    end

    # @return [void]
    def finish
      exit(0)
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

    # @yieldparam log [String]
    def debug(&block)
      @logger.debug(&block) if configuration.enables_debug?
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
      message = message.merge('id' => @server_request_id)
      debug do
        {
          kind: :write,
          message: message
        }
      end
      @writer.write(message)
      @client_response_handlers[@server_request_id] = block
      @server_request_id += 1
    end

    # @param message [Hash]
    # @return [void]
    def write_server_response(message)
      debug do
        {
          kind: :write,
          message: message
        }
      end
      @writer.write(message)
    end
  end
end
