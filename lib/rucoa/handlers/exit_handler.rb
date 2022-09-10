# frozen_string_literal: true

module Rucoa
  module Handlers
    class ExitHandler < Base
      def call
        server.finish
      end
    end
  end
end
