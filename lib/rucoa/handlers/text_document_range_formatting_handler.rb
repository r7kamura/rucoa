# frozen_string_literal: true

module Rucoa
  module Handlers
    class TextDocumentRangeFormattingHandler < Base
      def call
        respond(edits)
      end

      private

      # @return [Array<Hash>]
      def edits
        return [] unless formattable?

        correctable_replacements.map do |replacement_range, replacement|
          {
            newText: replacement,
            range: replacement_range.to_vscode_range
          }
        end
      end

      # @return [Boolean]
      def formattable?
        configuration.enables_formatting? &&
          source &&
          RubocopConfigurationChecker.call
      end

      # @return [Rucoa::Source]
      def source
        @source ||= source_store.get(uri)
      end

      # @return [String]
      def uri
        request.dig('params', 'textDocument', 'uri')
      end

      # @return [Rucoa::Range]
      def range
        @range ||= Range.from_vscode_range(
          request.dig('params', 'range')
        )
      end

      # @return [Array<RuboCop::Cop::Corrector>]
      def correctable_offenses
        offenses.select(&:corrector)
      end

      # @return [Array(Rucoa::Range, String)]
      def correctable_replacements
        replacements.select do |replacement_range, _|
          range.contains?(replacement_range)
        end
      end

      # @return [Array<RuboCop::Cop::Offense>]
      def offenses
        RubocopInvestigator.call(source: source)
      end

      # @return [Array(Rucoa::Range, String)]
      def replacements
        correctable_offenses.map(&:corrector).flat_map(&:as_replacements).map do |replacement_range, replacement|
          [
            Range.from_parser_range(replacement_range),
            replacement
          ]
        end
      end
    end
  end
end