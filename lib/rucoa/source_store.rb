# frozen_string_literal: true

module Rucoa
  class SourceStore
    def initialize
      @data = {}
    end

    # @yieldparam uri [String]
    # @return [Enumerable<String>]
    def each_uri(&block)
      @data.each_key(&block)
    end

    # @param uri [String]
    # @return [String, nil]
    def get(uri)
      @data[uri]
    end

    # @param source [Rucoa::Source]
    # @return [void]
    def update(source)
      @data[source.uri] = source
    end
  end
end
