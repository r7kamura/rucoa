# frozen_string_literal: true

require 'cgi'
require 'uri'

module Rucoa
  class SourceStore
    def initialize
      @data = {}
    end

    # @param source [Rucoa::Source]
    # @return [void]
    def update(source)
      @data[source.uri] = source
    end

    # @param uri [String]
    # @return [String, nil]
    def get(uri)
      @data[uri]
    end

    # @yieldparam uri [String]
    # @return [Enumerable<String>]
    def each_uri(&block)
      @data.each_key(&block)
    end

    private

    # @param uri [String]
    # @return [String]
    def path_from_uri(uri)
      ::CGI.unescape(
        ::URI.parse(uri).path || 'untitled'
      )
    end
  end
end
