# frozen_string_literal: true

require 'rubocop'

module Rucoa
  class RubocopRunner < ::RuboCop::Runner
    class << self
      # @param path [String]
      # @return [Array<RuboCop::Cop::Offense>]
      def call(path:)
        new(path: path).call
      end
    end

    # @param path [String]
    def initialize(path:)
      @path = path
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
      run([@path])
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
