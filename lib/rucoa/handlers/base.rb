# frozen_string_literal: true

module Rucoa
  module Handlers
    class Base
      class << self
        # @param server [Rucoa::Server]
        # @param request [Hash]
        # @return [void]
        def call(
          request:,
          server:
        )
          new(
            request: request,
            server: server
          ).call
        end
      end

      # @param request [Hash]
      # @param server [Rucoa::Server]
      def initialize(
        request:,
        server:
      )
        @request = request
        @server = server
      end

      # @return [void]
      def call
        raise ::NotImplementedError
      end

      private

      # @return [Hash]
      attr_reader :request

      # @return [Rucoa::Server]
      attr_reader :server

      # @param message [Hash]
      # @return [void]
      def respond(message)
        write(
          id: request['id'],
          result: message
        )
      end

      # @return [Rucoa::Configuration]
      def configuration
        @server.configuration
      end

      # @return [Rucoa::DefinitionStore]
      def definition_store
        @server.definition_store
      end

      # @return [Rucoa::SourceStore]
      def source_store
        @server.source_store
      end

      # @param message [Hash]
      # @return [void]
      def write(
        message,
        &block
      )
        @server.write(message, &block)
      end
    end
  end
end
