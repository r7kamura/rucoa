# frozen_string_literal: true

module Rucoa
  class Handler
    # @param request [Hash{Symbol => Object}]
    # @return [nil] If no response is prepared by handler.
    # @return [Hash{Symbol => Object}] If response is prepared by handler.
    def call(request)
      case request[:method]
      when :initialize
        on_initialize(request)
      end
    end

    private

    # @param request [Hash{Symbol => Object}]
    # @return [void]
    def on_initialize(_request)
      ::LanguageServer::Protocol::Interface::InitializeResult.new(
        capabilities: {}
      )
    end
  end
end
