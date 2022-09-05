# frozen_string_literal: true

module Rucoa
  class FormattingProvider
    class << self
      # @param source [Rucoa::Source]
      # @return [Array<Hash>]
      def call(source:)
        new(source: source).call
      end
    end

    # @param source [Rucoa::Source]
    def initialize(source:)
      @source = source
    end

    # @return [Array<Hash>]
    def call
      return [] unless RubocopConfigurationChecker.call

      [text_edit]
    end

    private

    # @return [Hash]
    def text_edit
      {
        newText: new_text,
        range: range
      }
    end

    # @return [String]
    def new_text
      RubocopAutocorrector.call(source: @source)
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
