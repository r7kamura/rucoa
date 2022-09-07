# frozen_string_literal: true

require 'json'

module Rucoa
  class MessageWriter
    DEFAULT_MESSAGE = {
      jsonrpc: '2.0'
    }.freeze

    private_constant :DEFAULT_MESSAGE

    class << self
      # @param message [Hash]
      # @return [String]
      def pack(message)
        body = DEFAULT_MESSAGE.merge(message).to_json
        "Content-Length: #{body.bytesize}\r\n\r\n#{body}"
      end
    end

    # @return [IO]
    attr_reader :io

    # @param io [IO]
    def initialize(io)
      @io = io
      @io.binmode
    end

    # @param message [Hash]
    # @return [void]
    def write(message)
      @io.print(
        self.class.pack(message)
      )
      @io.flush
    end
  end
end
