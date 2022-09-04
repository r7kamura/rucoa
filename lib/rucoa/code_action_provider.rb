# frozen_string_literal: true

module Rucoa
  class CodeActionProvider
    class << self
      # @param diagnostics [Array<Hash>]
      # @return [Array<Hash>]
      def call(diagnostics:)
        new(diagnostics: diagnostics).call
      end
    end

    # @param diagnostics [Array<Hash>]
    def initialize(diagnostics:)
      @diagnostics = diagnostics
    end

    # @return [Array<Hash>]
    def call
      correctable_diagnostics.map do |diagnostic|
        DiagnosticToCodeActionMapper.call(diagnostic)
      end
    end

    private

    # @return [Array<Hash>]
    def correctable_diagnostics
      @diagnostics.select do |diagnostic|
        diagnostic.dig('data', 'edits')
      end
    end

    class DiagnosticToCodeActionMapper
      class << self
        # @param diagnostic [Hash]
        # @return [Hash]
        def call(diagnostic)
          new(diagnostic).call
        end
      end

      # @param diagnostic [Hash]
      def initialize(diagnostic)
        @diagnostic = diagnostic
      end

      # @return [Hash]
      def call
        {
          diagnostics: diagnostics,
          edit: edit,
          isPreferred: preferred?,
          kind: kind,
          title: title
        }
      end

      private

      # @return [Hash]
      def edit
        {
          documentChanges: [
            {
              edits: @diagnostic.dig('data', 'edits'),
              textDocument: {
                uri: @diagnostic.dig('data', 'uri'),
                version: nil
              }
            }
          ]
        }
      end

      # @return [String]
      def cop_name
        @diagnostic.dig('data', 'cop_name')
      end

      # @return [Array]
      def diagnostics
        [@diagnostic]
      end

      # @return [Boolean]
      def preferred?
        true
      end

      # @return [String]
      def kind
        'quickfix'
      end

      # @return [String]
      def title
        "Autocorrect #{cop_name}"
      end
    end
  end
end
