# frozen_string_literal: true

require 'pathname'

module Rucoa
  class DefinitionArchiver
    RUBY_DEFINITIONS_DUMP_PATH = ::File.expand_path('../../data/definitions_ruby_3_1', __dir__).freeze
    private_constant :RUBY_DEFINITIONS_DUMP_PATH

    class << self
      # @param definitions [Array<Rucoa::Definition::Base>]
      # @return [void]
      def dump(definitions)
        pathname = ::Pathname.new(RUBY_DEFINITIONS_DUMP_PATH)
        pathname.parent.mkpath
        pathname.write(
          ::Marshal.dump(definitions)
        )
      end

      # @return [Array<Rucoa::Definition::Base>]
      def load
        ::Marshal.load(
          ::File.binread(RUBY_DEFINITIONS_DUMP_PATH)
        )
      end
    end
  end
end
