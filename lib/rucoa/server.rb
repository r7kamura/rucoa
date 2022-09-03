# frozen_string_literal: true

require 'language_server/protocol'

module Rucoa
  class Server
    class << self
      # @return [void]
      def start
        new.start
      end
    end

    def initialize
      @handler = Handler.new
      @reader = ::LanguageServer::Protocol::Transport::Stdio::Reader.new
      @writer = ::LanguageServer::Protocol::Transport::Stdio::Writer.new
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
