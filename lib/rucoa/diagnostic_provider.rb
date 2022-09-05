# frozen_string_literal: true

module Rucoa
  class DiagnosticProvider
    # @param source [Rucoa::Source]
    # @param uri [String]
    # @return [Array<Hash>]
    def self.call(source:, uri:)
      new(
        source: source,
        uri: uri
      ).call
    end

    # @param source [Rucoa::Source]
    # @param uri [String]
    def initialize(source:, uri:)
      @source = source
      @uri = uri
    end

    # @return [Array<Hash>]
    def call
      return [] unless RubocopConfigurationChecker.call

      offenses.map do |offense|
        OffenseToDiagnosticMapper.call(
          offense,
          uri: @uri
        )
      end
    end

    private

    # @return [Array<RuboCop::Cop::Offense>]
    def offenses
      RubocopInvestigator.call(source: @source)
    end

    class OffenseToDiagnosticMapper
      LSP_SEVERITY_NAME_TO_VALUE_MAP = {
        error: 1,
        hint: 4,
        information: 3,
        warning: 2
      }.freeze
      private_constant :LSP_SEVERITY_NAME_TO_VALUE_MAP

      RUBOCOP_SEVERITY_NAME_TO_LSP_SEVERITY_MAP = {
        convention: LSP_SEVERITY_NAME_TO_VALUE_MAP[:information],
        error: LSP_SEVERITY_NAME_TO_VALUE_MAP[:error],
        fatal: LSP_SEVERITY_NAME_TO_VALUE_MAP[:error],
        info: LSP_SEVERITY_NAME_TO_VALUE_MAP[:information],
        refactor: LSP_SEVERITY_NAME_TO_VALUE_MAP[:hint],
        warning: LSP_SEVERITY_NAME_TO_VALUE_MAP[:warning]
      }.freeze
      private_constant :RUBOCOP_SEVERITY_NAME_TO_LSP_SEVERITY_MAP

      class << self
        # @param offense [RuboCop::Cop::Offense]
        # @param uri [String]
        # @return [Hash]
        def call(offense, uri:)
          new(offense, uri: uri).call
        end
      end

      # @param offense [RuboCop::Cop::Offense]
      # @param uri [String]
      def initialize(offense, uri:)
        @offense = offense
        @uri = uri
      end

      # @return [Hash]
      def call
        {
          code: code,
          data: data,
          message: message,
          range: range,
          severity: severity,
          source: source
        }
      end

      private

      # @return [String]
      def code
        @offense.cop_name
      end

      # @return [Hash]
      def data
        {
          cop_name: @offense.cop_name,
          edits: edits,
          path: @offense.location.source_buffer.name,
          range: range,
          uri: @uri
        }
      end

      # @return [Array<Hash>, nil]
      def edits
        @offense.corrector&.as_replacements&.map do |range, replacement|
          {
            newText: replacement,
            range: Range.from_parser_range(range).to_vscode_range
          }
        end
      end

      # @return [String]
      def message
        @offense.message.delete_prefix("#{@offense.cop_name}: ")
      end

      # @return [Hash]
      def range
        Range.from_parser_range(@offense.location).to_vscode_range
      end

      # @return [Integer]
      def severity
        RUBOCOP_SEVERITY_NAME_TO_LSP_SEVERITY_MAP.fetch(@offense.severity.name, 1)
      end

      # @return [String]
      def source
        'RuboCop'
      end
    end
  end
end
