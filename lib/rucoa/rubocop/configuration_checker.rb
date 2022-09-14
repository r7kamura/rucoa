# frozen_string_literal: true

require 'pathname'

module Rucoa
  module Rubocop
    class ConfigurationChecker
      class << self
        # @return [Boolean]
        def call
          new.call
        end
      end

      # @return [Boolean]
      def call
        rubocop_configured_for_current_directory?
      end

      private

      # @return [Boolean]
      def rubocop_configured_for_current_directory?
        each_current_and_ancestor_pathname.any? do |pathname|
          pathname.join('.rubocop.yml').exist?
        end
      end

      # @return [Enumerable<Pathname>]
      def each_current_and_ancestor_pathname
        return to_enum(__method__) unless block_given?

        pathname = ::Pathname.pwd
        loop do
          yield pathname
          break if pathname.root?

          pathname = pathname.parent
        end
        self
      end
    end
  end
end
