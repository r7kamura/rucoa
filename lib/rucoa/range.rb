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
    # @param exclude_end [Boolean]
    def initialize(beginning, ending, exclude_end: true)
      @beginning = beginning
      @ending = ending
      @exclude_end = exclude_end
    end

    # @param range [Rucoa::Range]
    # @return [Boolean]
    def contains?(range)
      copy = with_including_end
      copy.include?(range.beginning) && copy.include?(range.ending)
    end

    # @param position [Rucoa::Position]
    # @return [Boolean]
    def include?(position)
      return false if position.line > @ending.line
      return false if position.line < @beginning.line
      return false if position.column < @beginning.column
      return false if position.column > @ending.column
      return false if position.column == @ending.column && @exclude_end

      true
    end

    # @return [Hash]
    def to_vscode_range
      {
        end: @ending.to_vscode_position,
        start: @beginning.to_vscode_position
      }
    end

    private

    # @return [Rucoa::Range]
    def with_including_end
      self.class.new(@beginning, @ending, exclude_end: false)
    end
  end
end
