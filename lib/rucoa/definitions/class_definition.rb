# frozen_string_literal: true

module Rucoa
  module Definitions
    class ClassDefinition < ModuleDefinition
      # @return [String, nil]
      attr_reader :super_class_chained_name

      # @return [String, nil]
      attr_accessor :super_class_fully_qualified_name

      # @param super_class_chained_name [String, nil]
      # @param super_class_fully_qualified_name [String, nil]
      def initialize(
        super_class_chained_name: nil,
        super_class_fully_qualified_name: nil,
        **keyword_arguments
      )
        super(**keyword_arguments)
        @super_class_chained_name = super_class_chained_name
        @super_class_fully_qualified_name = super_class_fully_qualified_name
      end
    end
  end
end
