# frozen_string_literal: true

module Rucoa
  module Handlers
    class InitializedHandler < Base
      include HandlerConcerns::ConfigurationRequestable

      def call
        request_workspace_configuration
        update_definitions
      end

      private

      # @return [Array<Rucoa::Definitions::Base>]
      def load_definitions
        Yard::DefinitionsLoader.load_globs(
          globs: ::YARD::Parser::SourceParser::DEFAULT_PATH_GLOB
        )
      end

      # @return [void]
      def update_definitions
        load_definitions.group_by(&:source_path).each do |source_path, definitions|
          next unless source_path

          definition_store.update_definitions_defined_in(
            source_path,
            definitions: definitions
          )
        end
      end
    end
  end
end
