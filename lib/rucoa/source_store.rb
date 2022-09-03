# frozen_string_literal: true

module Rucoa
  class SourceStore
    def initialize
      @data = {}
    end

    # @param uri [String]
    # @return [String, nil]
    def get(uri)
      @data[uri]
    end

    # @param uri [String]
    # @param content [String]
    # @return [void]
    def set(uri, content)
      @data[uri] = Source.new(content: content)
    end
  end
end
