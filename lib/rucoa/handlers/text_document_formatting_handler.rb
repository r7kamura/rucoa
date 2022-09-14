# frozen_string_literal: true

module Rucoa
  module Handlers
    class TextDocumentFormattingHandler < Base
      def call
        respond(edits)
      end

      private

      # @return [Boolean]
      def formattable?
        configuration.enables_formatting? &&
          source &&
          Rubocop::ConfigurationChecker.call
      end

      # @return [Array<Hash>]
      def edits
        return [] unless formattable?

        [text_edit]
      end

      # @return [Rucoa::Source, nil]
      def source
        @source ||= source_store.get(uri)
      end

      # @return [String]
      def uri
        request.dig('params', 'textDocument', 'uri')
      end

      # @return [Hash]
      def text_edit
        {
          newText: new_text,
          range: range
        }
      end

      # @return [String]
      def new_text
        Rubocop::Autocorrector.call(source: source)
      end

      # @return [Hash]
      def range
        Range.new(
          Position.new(
            column: 0,
            line: 1
          ),
          Position.new(
            column: @source.content.lines.last.length,
            line: @source.content.lines.count + 1
          )
        ).to_vscode_range
      end
    end
  end
end
