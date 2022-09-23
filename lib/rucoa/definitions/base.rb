# frozen_string_literal: true

module Rucoa
  module Definitions
    class Base
      # @return [String, nil]
      attr_reader :description

      # @return [Rucoa::Location, nil]
      attr_accessor :location

      # @param description [String, nil]
      # @param location [Rucoa::Location, nil]
      def initialize(
        description:,
        location:
      )
        @description = description
        @location = location
      end
    end
  end
end
