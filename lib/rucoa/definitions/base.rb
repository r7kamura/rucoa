# frozen_string_literal: true

module Rucoa
  module Definitions
    class Base
      # @return [Rucoa::Location]
      attr_reader :location

      # @param location [Rucoa::Location]
      def initialize(location:)
        @location = location
      end
    end
  end
end
