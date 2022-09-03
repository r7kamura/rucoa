# frozen_string_literal: true

require 'parser/current'

module Rucoa
  # Parses Ruby text code.
  class Parser
    class << self
      # @param text [String]
      # @return [Rucoa::Nodes::Base]
      def call(text)
        new(text).call
      end
    end

    # @param text [String]
    def initialize(text)
      @text = text
    end

    # @return [Rucoa::Nodes::Base]
    def call
      parser.parse(
        ::Parser::Source::Buffer.new(
          '',
          source: @text
        )
      )
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
