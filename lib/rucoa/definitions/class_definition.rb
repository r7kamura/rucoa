# frozen_string_literal: true

module Rucoa
  module Definitions
    class ClassDefinition < ModuleDefinition
      # @return [Arra<String>, nil]
      attr_reader :module_nesting

      # @return [Array<String>]
      attr_reader :included_module_chained_names

      # @return [Array<String>]
      attr_accessor :included_module_fully_qualified_names

      # @return [String, nil]
      attr_reader :super_class_chained_name

      # @return [String, nil]
      attr_accessor :super_class_fully_qualified_name

      # @param included_module_chained_names [Array<String>]
      # @param included_module_fully_qualified_names [Array<String>]
      # @param module_nesting [Array<String>, nil]
      # @param super_class_chained_name [String, nil]
      # @param super_class_fully_qualified_name [String, nil]
      def initialize(
        included_module_chained_names: [],
        included_module_fully_qualified_names: [],
        module_nesting: nil,
        super_class_chained_name: nil,
        super_class_fully_qualified_name: nil,
        **keyword_arguments
      )
        super(**keyword_arguments)
        @included_module_chained_names = included_module_chained_names
        @included_module_fully_qualified_names = included_module_fully_qualified_names
        @module_nesting = module_nesting
        @super_class_chained_name = super_class_chained_name
        @super_class_fully_qualified_name = super_class_fully_qualified_name
      end
    end
  end
end
