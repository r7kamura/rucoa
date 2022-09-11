# frozen_string_literal: true

module Rucoa
  module Handlers
    class WorkspaceDidChangeConfigurationHandler < Base
      include HandlerConcerns::DiagnosticsPublishable

      def call
        configuration.update(settings)
        publish_diagnostics_on_each_source
      end

      private

      # @return [Hash]
      def settings
        request.dig('params', 'settings')
      end
    end
  end
end
