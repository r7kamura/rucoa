# frozen_string_literal: true

module Rucoa
  module Types
    class MethodType
      # @return [String]
      attr_reader :parameters_string

      # @return [String]
      attr_reader :return_type

      # @param parameters_string [String]
      # @param return_type [String]
      def initialize(
        parameters_string:,
        return_type:
      )
        @parameters_string = parameters_string
        @return_type = return_type
      end
    end
  end
end
