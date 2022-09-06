# frozen_string_literal: true

module Rucoa
  module HandlerConcerns
    module DiagnosticsPublishable
      private

      # @param uri [String]
      # @return [Array<Hash>]
      def diagnostics_on(uri)
        return [] unless configuration.enables_diagnostics?

        DiagnosticProvider.call(
          source: source_store.get(uri),
          uri: uri
        )
      end

      # @param uri [String]
      # @return [void]
      def publish_diagnostics_on(uri)
        write(
          method: 'textDocument/publishDiagnostics',
          params: {
            diagnostics: diagnostics_on(uri),
            uri: uri
          }
        )
      end
    end
  end
end
