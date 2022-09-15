# frozen_string_literal: true

module Rucoa
  module Definitions
    class ClassDefinition < ModuleDefinition
      # @return [String, nil]
      attr_reader :super_class_name

      # @param super_class_name [String, nil]
      def initialize(super_class_name:, **keyword_arguments)
        super(**keyword_arguments)
        @super_class_name = super_class_name
      end
    end
  end
end
