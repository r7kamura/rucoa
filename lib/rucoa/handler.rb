# frozen_string_literal: true

module Rucoa
  class Handler
    # @param message [LanguageServer::Protocol::Interface::RequestMessage]
    def call(message)
      warn message[:method]
    end
  end
end
