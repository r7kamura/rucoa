# frozen_string_literal: true

module Rucoa
  class Configuration
    def initialize
      @settings = {}
    end

    # @return [void]
    def disable_code_action
      disable_feature('codeAction')
    end

    # @return [void]
    def disable_completion
      disable_feature('completion')
    end

    # @return [void]
    def disable_diagnostics
      disable_feature('diagnostics')
    end

    # @return [void]
    def disable_document_symbol
      disable_feature('documentSymbol')
    end

    # @return [void]
    def disable_formatting
      disable_feature('formatting')
    end

    # @return [void]
    def disable_selection_range
      disable_feature('selectionRange')
    end

    # @return [void]
    def disable_signature_help
      disable_feature('signatureHelp')
    end

    # @return [void]
    def enable_debug
      @settings ||= {}
      @settings['base'] ||= {}
      @settings['base']['debug'] = true
    end

    # @return [Boolean]
    # @example returns false if the configuration is empty
    #   configuration = Rucoa::Configuration.new
    #   expect(configuration).not_to be_enables_debug
    # @example returns true if the configuration enables debug
    #   configuration = Rucoa::Configuration.new
    #   configuration.update('base' => { 'debug' => true })
    #   expect(configuration).to be_enables_debug
    def enables_debug?
      fetch('base', 'debug', default: false)
    end

    # @return [Boolean]
    # @example returns true if the configuration is empty
    #   configuration = Rucoa::Configuration.new
    #   expect(configuration).to be_enables_code_action
    # @example returns false if the configuration disables code action
    #   configuration = Rucoa::Configuration.new
    #   configuration.disable_code_action
    #   expect(configuration).not_to be_enables_code_action
    def enables_code_action?
      enables_feature?('codeAction')
    end

    # @return [Boolean]
    def enables_completion?
      enables_feature?('completion')
    end

    # @return [Boolean]
    def enables_diagnostics?
      enables_feature?('diagnostics')
    end

    # @return [Boolean]
    def enables_document_symbol?
      enables_feature?('documentSymbol')
    end

    # @return [Boolean]
    def enables_formatting?
      enables_feature?('formatting')
    end

    # @return [Boolean]
    def enables_selection_range?
      enables_feature?('selectionRange')
    end

    # @return [Boolean]
    def enables_signature_help?
      enables_feature?('signatureHelp')
    end

    # @param settings [Hash]
    # @return [void]
    def update(settings)
      @settings = settings
    end

    private

    # @param feature [String]
    # @return [void]
    def disable_feature(feature)
      @settings ||= {}
      @settings['feature'] ||= {}
      @settings['feature'][feature] ||= {}
      @settings['feature'][feature]['enable'] = false
    end

    # @param feature [String]
    # @return [Boolean]
    def enables_feature?(feature)
      fetch('feature', feature, 'enable', default: true)
    end

    # @param keys [Array<String>]
    # @param default [Object]
    # @return [Object]
    def fetch(*keys, default:)
      value = @settings.dig(*keys)
      if value.nil?
        default
      else
        value
      end
    end
  end
end
