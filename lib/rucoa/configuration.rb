# frozen_string_literal: true

module Rucoa
  class Configuration
    def initialize
      @settings = {}
    end

    # @return [void]
    def disable_code_action
      disable('codeAction')
    end

    # @return [void]
    def disable_diagnostics
      disable('diagnostics')
    end

    # @return [void]
    def disable_document_symbol
      disable('documentSymbol')
    end

    # @return [void]
    def disable_formatting
      disable('formatting')
    end

    # @return [void]
    def disable_selection_range
      disable('selectionRange')
    end

    # @return [void]
    def disable_signature_help
      disable('signatureHelp')
    end

    # @return [Boolean]
    def enables_code_action?
      enables?('codeAction')
    end

    # @return [Boolean]
    def enables_diagnostics?
      enables?('diagnostics')
    end

    # @return [Boolean]
    def enables_document_symbol?
      enables?('documentSymbol')
    end

    # @return [Boolean]
    def enables_formatting?
      enables?('formatting')
    end

    # @return [Boolean]
    def enables_selection_range?
      enables?('selectionRange')
    end

    # @return [Boolean]
    def enables_signature_help?
      enables?('signatureHelp')
    end

    # @param settings [Hash]
    # @return [void]
    def update(settings)
      @settings = settings
    end

    private

    # @param feature [String]
    # @return [void]
    def disable(feature)
      @settings ||= {}
      @settings['feature'] ||= {}
      @settings['feature'][feature] ||= {}
      @settings['feature'][feature]['enable'] = false
    end

    # @param feature [String]
    # @return [Boolean]
    def enables?(feature)
      value = @settings.dig('feature', feature, 'enable')
      if value.nil?
        true
      else
        value
      end
    end
  end
end
