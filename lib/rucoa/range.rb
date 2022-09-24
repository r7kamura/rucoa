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
    # @param including_ending [Boolean]
    def initialize(
      beginning,
      ending,
      including_ending: true
    )
      @beginning = beginning
      @ending = ending
      @including_ending = including_ending
    end

    # @param other [Rucoa::Range]
    # @return [Boolean]
    def ==(other)
      beginning == other.beginning && ending == other.ending
    end

    # @param range [Rucoa::Range]
    # @return [Boolean]
    # @example returns true when the range is contained in self
    #   range = Rucoa::Range.new(
    #     Rucoa::Position.new(
    #       column: 0,
    #       line: 0
    #     ),
    #     Rucoa::Position.new(
    #       column: 0,
    #       line: 2
    #     )
    #   )
    #   expect(range).to contain(
    #     Rucoa::Range.new(
    #       Rucoa::Position.new(
    #         column: 0,
    #         line: 0
    #       ),
    #       Rucoa::Position.new(
    #         column: 0,
    #         line: 0
    #       )
    #     )
    #   )
    def contain?(range)
      include?(range.beginning) && include?(range.ending)
    end

    # @param position [Rucoa::Position]
    # @return [Boolean]
    # @example returns true when the position is included in self
    #   range = Rucoa::Range.new(
    #     Rucoa::Position.new(
    #       column: 0,
    #       line: 0
    #     ),
    #     Rucoa::Position.new(
    #       column: 0,
    #       line: 2
    #     )
    #   )
    #   expect(range).to include(
    #     Rucoa::Position.new(
    #       column: 0,
    #       line: 0
    #     )
    #   )
    #   expect(range).to include(
    #     Rucoa::Position.new(
    #       column: 0,
    #       line: 1
    #     )
    #   )
    #   expect(range).to include(
    #     Rucoa::Position.new(
    #       column: 0,
    #       line: 2
    #     )
    #   )
    #   expect(range).not_to include(
    #     Rucoa::Position.new(
    #       column: 0,
    #       line: 3
    #     )
    #   )
    def include?(position)
      return false if position.line > @ending.line
      return false if position.line < @beginning.line
      return false if position.column < @beginning.column
      return false if position.column > @ending.column
      return false if position.column == @ending.column && !@including_ending

      true
    end

    # @return [Hash]
    def to_vscode_range
      {
        end: @ending.to_vscode_position,
        start: @beginning.to_vscode_position
      }
    end
  end
end
