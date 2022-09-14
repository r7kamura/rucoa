# frozen_string_literal: true

module Rucoa
  module HandlerConcerns
    module DiagnosticsPublishable
      private

      # @param uri [String]
      # @return [Array<Hash>]
      def diagnostics_on(uri)
        return [] unless configuration.enables_diagnostics?

        DiagnosticProvider.call(
          source: source_store.get(uri),
          uri: uri
        )
      end

      # @param uri [String]
      # @return [void]
      def clear_diagnostics_on(uri)
        write(
          method: 'textDocument/publishDiagnostics',
          params: {
            diagnostics: [],
            uri: uri
          }
        )
      end

      # @param uri [String]
      # @return [void]
      def publish_diagnostics_on(uri)
        write(
          method: 'textDocument/publishDiagnostics',
          params: {
            diagnostics: diagnostics_on(uri),
            uri: uri
          }
        )
      end

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
          return [] unless Rubocop::ConfigurationChecker.call

          offenses.map do |offense|
            OffenseToDiagnosticMapper.call(
              offense,
              source: @source,
              uri: @uri
            )
          end
        end

        private

        # @return [Array<RuboCop::Cop::Offense>]
        def offenses
          Rubocop::Investigator.call(source: @source)
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
            # @param source [Rucoa::Source]
            # @param uri [String]
            # @return [Hash]
            def call(offense, source:, uri:)
              new(
                offense,
                source: source,
                uri: uri
              ).call
            end
          end

          # @param offense [RuboCop::Cop::Offense]
          # @param source [Rucoa::Source]
          # @param uri [String]
          def initialize(offense, source:, uri:)
            @offense = offense
            @source = source
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
  end
end
