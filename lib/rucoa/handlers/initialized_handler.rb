# frozen_string_literal: true

module Rucoa
  module Handlers
    class InitializedHandler < Base
      include HandlerConcerns::ConfigurationRequestable

      def call
        request_workspace_configuration
        update_sources
        update_definitions
      end

      private

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

      # @return [void]
      def update_sources
        sources.each do |source|
          source_store.update(source)
        end
      end

      # @return [Array<Rucoa::Definitions::Base>]
      def load_definitions
        Yard::DefinitionsLoader.load_globs(
          globs: [glob]
        )
      end

      # @return [Array<Rucoa::Source>]
      def sources
        @sources ||= pathnames.map do |pathname|
          Source.new(
            content: pathname.read,
            uri: "file://#{pathname}"
          )
        end
      end

      # @return [Array<Pathname>]
      def pathnames
        ::Pathname.glob(glob)
      end

      # @return [String]
      def glob
        ::File.expand_path('{app,lib}/**/*.rb')
      end
    end
  end
end
