# frozen_string_literal: true

module Rucoa
  module HandlerConcerns
    module TextDocumentPositionParameters
      private

      # @return [Rucoa::Position]
      def position
        @position ||= Position.from_vscode_position(
          request.dig('params', 'position')
        )
      end
    end
  end
end
