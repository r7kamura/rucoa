# frozen_string_literal: true

module Rucoa
  class Range
    class << self
      # @param range [Parser::Source::Range]
      # @return [Rucoa::Range]
      def from_parser_range(range)
        new(
          Position.from_parser_range_beginning(range),
          Position.from_parser_range_ending(range)
        )
      end
    end

    # @param beginning [Rucoa::Position]
    # @param ending [Ruoca::Position]
    def initialize(beginning, ending)
      @beginning = beginning
      @ending = ending
    end

    # @param position [Rucoa::Position]
    # @return [Boolean]
    def include?(position)
      !exclude?(position)
    end

    # @return [Hash]
    def to_vscode_range
      {
        end: @ending.to_vscode_position,
        start: @beginning.to_vscode_position
      }
    end

    private

    # @param position [Rucoa::Position]
    # @return [Boolean]
    def exclude?(position)
      position.line > @ending.line ||
        position.line < @beginning.line ||
        (position.line == @beginning.line && position.column < @beginning.column) ||
        (position.line == @ending.line && position.column >= @ending.column)
    end
  end
end
