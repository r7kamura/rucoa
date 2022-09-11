# frozen_string_literal: true

module Rucoa
  module Handlers
    class InitializedHandler < Base
      include HandlerConcerns::DiagnosticsPublishable

      def call
        request_workspace_configuration
        load_definitions
      end

      private

      # @return [void]
      def load_definitions
        YardGlobDocumentLoader.call(
          globs: ::YARD::Parser::SourceParser::DEFAULT_PATH_GLOB
        )
      end

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
    end
  end
end
