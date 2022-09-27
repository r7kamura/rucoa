# frozen_string_literal: true

module Rucoa
  module Handlers
    class InitializedHandler < Base
      include HandlerConcerns::ConfigurationRequestable

      def call
        request_workspace_configuration
        update_source_store
        update_definition_store
      end

      private

      # @return [String]
      def glob
        ::File.expand_path('{app,lib}/**/*.rb')
      end

      # @return [Array<Pathname>]
      def pathnames
        ::Pathname.glob(glob)
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

      # @return [void]
      def update_definition_store
        sources.each do |source|
          definition_store.update_from(source)
        end
      end

      # @return [void]
      def update_source_store
        sources.each do |source|
          source_store.update(source)
        end
      end
    end
  end
end
