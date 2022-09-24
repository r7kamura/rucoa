# frozen_string_literal: true

module Rucoa
  module Definitions
    class ModuleDefinition < ConstantDefinition
      # @return [Arra<String>, nil]
      attr_reader :module_nesting

      # @return [Array<String>]
      attr_reader :included_module_chained_names

      # @return [Array<String>]
      attr_accessor :included_module_fully_qualified_names

      # @return [Array<String>]
      attr_reader :prepended_module_chained_names

      # @return [Array<String>]
      attr_accessor :prepended_module_fully_qualified_names

      # @param included_module_chained_names [Array<String>]
      # @param included_module_fully_qualified_names [Array<String>]
      # @param prepended_module_chained_names [Array<String>]
      # @param prepended_module_fully_qualified_names [Array<String>]
      # @param module_nesting [Array<String>, nil]
      def initialize(
        included_module_chained_names: [],
        included_module_fully_qualified_names: [],
        module_nesting: nil,
        prepended_module_chained_names: [],
        prepended_module_fully_qualified_names: [],
        **keyword_arguments
      )
        super(**keyword_arguments)
        @included_module_chained_names = included_module_chained_names
        @included_module_fully_qualified_names = included_module_fully_qualified_names
        @module_nesting = module_nesting
        @prepended_module_chained_names = prepended_module_chained_names
        @prepended_module_fully_qualified_names = prepended_module_fully_qualified_names
      end
    end
  end
end
