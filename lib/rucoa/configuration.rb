# frozen_string_literal: true

module Rucoa
  class Configuration
    DEFAULT_SETTINGS = {
      'base' => {
        'enable' => 'auto',
        'useBundler' => 'auto'
      },
      'feature' => {
        'codeAction' => {
          'enable' => true
        },
        'diagnostics' => {
          'enable' => true
        },
        'formatting' => {
          'enable' => true
        },
        'selectionRange' => {
          'enable' => true
        }
      }
    }.freeze

    def initialize
      reset
    end

    # @return [Boolean]
    def enables_code_action?
      @settings.dig('feature', 'codeAction', 'enable')
    end

    # @return [Boolean]
    def enables_diagnostics?
      @settings.dig('feature', 'diagnostics', 'enable')
    end

    # @return [Boolean]
    def enables_formatting?
      @settings.dig('feature', 'formatting', 'enable')
    end

    # @return [Boolean]
    def enables_selection_range?
      @settings.dig('feature', 'selectionRange', 'enable')
    end

    # @param settings [Hash]
    # @return [void]
    def update(settings)
      @settings = settings
    end

    private

    # @return [void]
    def reset
      @settings = DEFAULT_SETTINGS.dup
    end
  end
end
