# frozen_string_literal: true

module Rucoa
  module HandlerConcerns
    module ConfigurationRequestable
      include HandlerConcerns::DiagnosticsPublishable

      private

      # @return [void]
      def request_workspace_configuration
        write(
          method: 'workspace/configuration',
          params: {
            items: [
              {
                section: 'rucoa'
              }
            ]
          }
        ) do |response|
          configuration.update(response['result'][0])
          publish_diagnostics_on_each_source
        end
      end

      # @return [void]
      def publish_diagnostics_on_each_source
        source_store.each_uri do |uri|
          publish_diagnostics_on(uri)
        end
      end
    end
  end
end
