# frozen_string_literal: true

module Rucoa
  # Stores text documents per document URI.
  class DocumentStore
    def initialize
      @data = {}
    end

    # @param uri [String]
    # @return [String, nil]
    def get(uri)
      @data[uri]
    end

    # @param uri [String]
    # @param text [String]
    # @return [void]
    def set(uri, text)
      @data[uri] = text
    end
  end
end
