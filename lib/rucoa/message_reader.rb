# frozen_string_literal: true

require 'json'

module Rucoa
  class MessageReader
    # @param io [IO]
    def initialize(io)
      @io = io
      @io.binmode
    end

    # @yieldparam message [Hash]
    # @return [Enumerator<Hash>, void]
    def read
      return enum_for(:read) unless block_given?

      while (buffer = @io.gets("\r\n\r\n"))
        content_length = buffer[/Content-Length: (\d+)/i, 1]
        raise Errors::ContentLengthHeaderNotFound unless content_length

        body = @io.read(content_length.to_i)
        raise Errors::ContentLengthHeaderNotFound unless body

        yield ::JSON.parse(body)
      end
    end
  end
end
