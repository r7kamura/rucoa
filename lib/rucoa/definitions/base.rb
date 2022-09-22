# frozen_string_literal: true

module Rucoa
  module Definitions
    class Base
      # @return [Rucoa::Location, nil]
      attr_accessor :location

      # @param location [Rucoa::Location, nil]
      def initialize(location:)
        @location = location
      end
    end
  end
end
