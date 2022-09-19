# frozen_string_literal: true

require 'parser/current'

module Rucoa
  class Parser
    class << self
      # @param path [String]
      # @param text [String]
      # @return [Rucoa::ParseResult]
      # @example returns non-failed parse result for valid Ruby source
      #   result = Rucoa::Parser.call(
      #     path: '/path/to/foo.rb',
      #     text: 'foo'
      #   )
      #   expect(result).not_to be_failed
      # @example returns failed parse result for invalid Ruby source
      #   result = Rucoa::Parser.call(
      #     path: '/path/to/foo.rb',
      #     text: 'foo('
      #   )
      #   expect(result).to be_failed
      def call(
        path:,
        text:
      )
        new(
          path: path,
          text: text
        ).call
      end
    end

    # @param path [String]
    # @param text [String]
    def initialize(
      path:,
      text:
    )
      @path = path
      @text = text
    end

    # @return [Rucoa::ParseResult]
    def call
      root_node, comments = parser.parse_with_comments(
        ::Parser::Source::Buffer.new(
          @path,
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
