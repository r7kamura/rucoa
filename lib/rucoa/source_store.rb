# frozen_string_literal: true

require 'cgi'
require 'uri'

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
      @data[uri] = Source.new(
        content: content,
        path: path_from_uri(uri)
      )
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
