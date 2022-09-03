# frozen_string_literal: true

require 'language_server/protocol'

module Rucoa
  class Server
    # @param reader [IO]
    # @param writer [IO]
    def initialize(reader:, writer:)
      @handler = Handler.new
      @reader = ::LanguageServer::Protocol::Transport::Io::Reader.new(reader)
      @writer = ::LanguageServer::Protocol::Transport::Io::Writer.new(writer)
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

    # @param request [Hash{Symbol => Object}]
    # @return [Object]
    def handle(request)
      @handler.call(request)
    end

    # @yieldparam request [Hash{Symbol => Object}]
    # @return [void]
    def read(&block)
      @reader.read(&block)
    end

    # @param request [Hash{Symbol => Object}]
    # @param result [Object]
    # @return [void]
    def write(request:, result:)
      @writer.write(
        {
          id: request[:id],
          result: result
        }
      )
    end
  end
end
