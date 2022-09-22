# frozen_string_literal: true

require 'parser/current'

module Rucoa
  class Parser
    class << self
      # @param text [String]
      # @param uri [String]
      # @return [Rucoa::ParseResult]
      # @example returns non-failed parse result for valid Ruby source
      #   result = Rucoa::Parser.call(
      #     text: 'foo',
      #     uri: 'file:///path/to/foo.rb'
      #   )
      #   expect(result).not_to be_failed
      # @example returns failed parse result for invalid Ruby source
      #   result = Rucoa::Parser.call(
      #     text: 'foo(',
      #     uri: 'file:///path/to/foo.rb'
      #   )
      #   expect(result).to be_failed
      def call(
        text:,
        uri:
      )
        new(
          text: text,
          uri: uri
        ).call
      end
    end

    # @param text [String]
    # @param uri [String]
    def initialize(
      text:,
      uri:
    )
      @text = text
      @uri = uri
    end

    # @return [Rucoa::ParseResult]
    def call
      root_node, comments = parser.parse_with_comments(
        ::Parser::Source::Buffer.new(
          @uri,
          source: @text
        )
      )
      ParseResult.new(
        associations: ::Parser::Source::Comment.associate_locations(
          root_node,
          comments
        ),
        root_node: root_node
      )
    rescue ::Parser::SyntaxError
      ParseResult.new(failed: true)
    end

    private

    # @return [Parser::Base]
    def parser
      parser = ::Parser::CurrentRuby.new(ParserBuilder.new)
      parser.diagnostics.all_errors_are_fatal = true
      parser.diagnostics.ignore_warnings = true
      parser
    end
  end
end
