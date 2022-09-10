# frozen_string_literal: true

module Rucoa
  module Handlers
    class InitializedHandler < Base
      include HandlerConcerns::ConfigurationRequestable

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
    end
  end
end
