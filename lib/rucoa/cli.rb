# frozen_string_literal: true

module Rucoa
  class Cli
    # @param argv [Array<String>]
    # @return [void]
    def self.call(argv)
      new(argv).call
    end

    # @param argv [Array<String>]
    def initialize(argv)
      @argv = argv
    end

    # @return [void]
    def call; end
  end
end
