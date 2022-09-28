# frozen_string_literal: true

module Rucoa
  module HandlerConcerns
    module TextDocumentUriParameters
      private

      # @return [String, nil]
      def parameter_uri
        @parameter_uri ||= request.dig('params', 'textDocument', 'uri')
      end

      # @return [Rucoa::Source, nil]
      def source
        return unless parameter_uri

        @source ||= source_store.get(parameter_uri)
      end
    end
  end
end
