# frozen_string_literal: true

module Rucoa
  class RangeFormattingProvider
    class << self
      # @param range [Rucoa::Range]
      # @param source [Rucoa::Source]
      # @return [Array<Hash>]
      def call(range:, source:)
        new(range: range, source: source).call
      end
    end

    # @param range [Rucoa::Range]
    # @param source [Rucoa::Source]
    def initialize(range:, source:)
      @range = range
      @source = source
    end

    # @return [Array<Hash>]
    def call
      return [] unless RubocopConfigurationChecker.call

      edits
    end

    private

    # @return [RuboCop::Cop::Offense]
    def correctable_offenses
      offenses.select(&:corrector)
    end

    # @return [Array(Rucoa::Range, String)]
    def correctable_replacements
      replacements.select do |range, _|
        @range.contains?(range)
      end
    end

    # @return [Array<Hash>]
    def edits
      correctable_replacements.map do |range, replacement|
        {
          newText: replacement,
          range: range.to_vscode_range
        }
      end
    end

    # @return [Array<RuboCop::Cop::Offense>]
    def offenses
      RubocopInvestigator.call(source: @source)
    end

    # @return [Array(Rucoa::Range, String)]
    def replacements
      correctable_offenses.map(&:corrector).flat_map(&:as_replacements).map do |range, replacement|
        [
          Range.from_parser_range(range),
          replacement
        ]
      end
    end
  end
end
