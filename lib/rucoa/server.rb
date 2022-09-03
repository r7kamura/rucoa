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
      @reader.read do |message|
        @handler.call(message)
      end
    end
  end
end
