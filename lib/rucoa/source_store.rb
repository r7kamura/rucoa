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
    # @return [String, nil]
    def path_from_uri(uri)
      path =
        if uri.start_with?('untitled:')
          uri.split(':', 2).last
        else
          ::URI.parse(uri).path
        end
      return nil unless path

      ::CGI.unescape(path)
    end
  end
end
