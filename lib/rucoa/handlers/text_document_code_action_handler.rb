# frozen_string_literal: true

module Rucoa
  module Handlers
    class TextDocumentCodeActionHandler < Base
      def call
        return unless diagnostics

        respond(code_actions)
      end

      private

      # @return [Array<Hash>]
      def code_actions
        return [] unless configuration.enables_code_action?

        CodeActionProvider.call(
          diagnostics: diagnostics
        )
      end

      # @return [Array<Hash>, nil]
      def diagnostics
        @diagnostics ||= request.dig('params', 'context', 'diagnostics')
      end
    end
  end
end
