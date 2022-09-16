# frozen_string_literal: true

require 'rubocop'

module Rucoa
  module Rubocop
    class Autocorrector < ::RuboCop::Runner
      class << self
        # @param source [Rucoa::Source]
        # @return [String]
        def call(source:)
          new(source: source).call
        end
      end

      # @param source [Rucoa::Source]
      def initialize(source:)
        @source = source
        super(
          ::RuboCop::Options.new.parse(
            %w[
              --stderr
              --force-exclusion
              --format RuboCop::Formatter::BaseFormatter
              -A
            ]
          ).first,
          ::RuboCop::ConfigStore.new
        )
      end

      # @return [String]
      def call
        @options[:stdin] = @source.content
        run([path])
        @options[:stdin]
      end

      private

      # @return [String]
      def path
        if @source.untitled? || @source.path.nil?
          'untitled'
        else
          @source.path
        end
      end
    end
  end
end
