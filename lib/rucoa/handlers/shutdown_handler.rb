# frozen_string_literal: true

module Rucoa
  module Handlers
    class ShutdownHandler < Base
      def call
        server.shutting_down = true
        respond(nil)
      end
    end
  end
end
