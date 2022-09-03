# frozen_string_literal: true

module Rucoa
  class DiagnosticProvider
    # @param source [Rucoa::Source]
    # @return [Array<Hash>]
    def self.call(source:)
      new(source: source).call
    end

    # @param source [Rucoa::Source]
    def initialize(source:)
      @source = source
    end

    # @return [Array<Hash>]
    def call
      offenses.map do |offense|
        OffenseToDiagnosticMapper.call(offense: offense)
      end
    end

    private

    # @return [Array<RuboCop::Cop::Offense>]
    def offenses
      RubocopRunner.call(path: @source.path)
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
        # @return [Hash]
        def call(offense:)
          new(offense: offense).call
        end
      end

      # @param offense [RuboCop::Cop::Offense]
      def initialize(offense:)
        @offense = offense
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
          correctable: @offense.correctable?,
          path: @offense.location.source_buffer.name,
          range: range
        }
      end

      # @return [String]
      def message
        @offense.message.delete_prefix("#{@offense.cop_name}: ")
      end

      # @return [Hash]
      def range
        Range.from_rubocop_offense(@offense).to_vscode_range
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
