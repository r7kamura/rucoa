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

      # @param hash [Hash]
      # @return [Rucoa::Range]
      def from_vscode_range(hash)
        new(
          Position.from_vscode_position(hash['start']),
          Position.from_vscode_position(hash['end'])
        )
      end
    end

    # @return [Rucoa::Position]
    attr_reader :beginning

    # @return [Rucoa::Position]
    attr_reader :ending

    # @param beginning [Rucoa::Position]
    # @param ending [Ruoca::Position]
    def initialize(beginning, ending)
      @beginning = beginning
      @ending = ending
    end

    # @param range [Rucoa::Range]
    # @return [Boolean]
    def contains?(range)
      (include?(range.beginning) && include?(range.ending)) || self == range
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

    # @note Override.
    # @param other [Rucoa::Range]
    # @return [Boolean]
    def ==(other)
      @beginning == other.beginning && @ending == other.ending
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
