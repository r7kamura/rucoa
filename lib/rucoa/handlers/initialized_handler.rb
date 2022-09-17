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
      def update_sources
        sources.each do |source|
          source_store.update(source)
        end
      end

      # @return [Array<Rucoa::Definitions::Base>]
      def update_definitions
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
