# frozen_string_literal: true

module Rucoa
  class Server
    # @param reader [IO]
    # @param writer [IO]
    def initialize(reader:, writer:)
      @handler = Handler.new
      @reader = MessageReader.new(reader)
      @writer = MessageWriter.new(writer)
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
      @handler.call(request)
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
  end
end
