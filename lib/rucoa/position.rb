# frozen_string_literal: true

module Rucoa
  class Position
    class << self
      # @param range [Parser::Source::Range]
      # @return [Rucoa::Position]
      def from_parser_range_beginning(range)
        new(
          column: range.column,
          line: range.line
        )
      end

      # @param range [Parser::Source::Range]
      # @return [Rucoa::Position]
      def from_parser_range_ending(range)
        new(
          column: range.last_column,
          line: range.last_line
        )
      end

      # @param hash [Hash{String => Integer}]
      # @return [Rucoa::Position]
      def from_vscode_position(hash)
        new(
          column: hash['character'],
          line: hash['line'] + 1
        )
      end
    end

    # @return [Integer]
    attr_reader :column

    # @return [Integer]
    attr_reader :line

    # @param column [Integer] 0-origin column number
    # @param line [Integer] 1-origin line number
    def initialize(
      column: 0,
      line: 1
    )
      @column = column
      @line = line
    end

    # @param other [Rucoa::Position]
    # @return [Boolean]
    def ==(other)
      column == other.column && line == other.line
    end

    # @param text [String]
    # @return [Integer]
    def to_index_of(text)
      text.each_line.take(@line - 1).sum(&:length) + @column
    end

    # @return [Rucoa::Range]
    def to_range
      Range.new(self, self)
    end

    # @return [Hash]
    def to_vscode_position
      {
        'character' => @column,
        'line' => @line - 1
      }
    end
  end
end
