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
      @reader = ::LanguageServer::Protocol::Transport::Stdio::Reader.new
      @writer = ::LanguageServer::Protocol::Transport::Stdio::Writer.new
    end

    # @return [void]
    def start
      @reader.read do |message|
        p message
      end
    end
  end
end
