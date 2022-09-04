# frozen_string_literal: true

require 'rubocop'

module Rucoa
  class RubocopInvestigator < ::RuboCop::Runner
    class << self
      # @param source [Rucoa::Source]
      # @return [Array<RuboCop::Cop::Offense>]
      def call(source:)
        new(source: source).call
      end
    end

    # @param source [Rucoa::Source]
    def initialize(source:)
      @source = source
      @offenses = []
      super(
        ::RuboCop::Options.new.parse(
          %w[
            --stderr
            --force-exclusion
            --format RuboCop::Formatter::BaseFormatter
          ]
        ).first,
        ::RuboCop::ConfigStore.new
      )
    end

    # @return [Array<RuboCop::Cop::Offense>]
    def call
      @options[:stdin] = @source.content
      run([@source.path])
      @offenses
    end

    private

    # @param file [String]
    # @param offenses [Array<RuboCop::Cop::Offense>]
    # @return [void]
    def file_finished(file, offenses)
      @offenses = offenses
      super
    end
  end
end
