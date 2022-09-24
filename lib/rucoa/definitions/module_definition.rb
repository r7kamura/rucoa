# frozen_string_literal: true

module Rucoa
  module Definitions
    class ModuleDefinition < ConstantDefinition
      # @return [Array<String>]
      attr_accessor :extended_module_qualified_names

      # @return [Array<Rucoa::UnqualifiedName>]
      attr_accessor :extended_module_unqualified_names

      # @return [Array<String>]
      attr_accessor :included_module_qualified_names

      # @return [Array<Rucoa::UnqualifiedName>]
      attr_accessor :included_module_unqualified_names

      # @return [Array<String>]
      attr_accessor :prepended_module_qualified_names

      # @return [Array<Rucoa::UnqualifiedName>]
      attr_accessor :prepended_module_unqualified_names

      # @param extended_module_qualified_names [Array<String>]
      # @param extended_module_unqualified_names [Array<String>]
      # @param included_module_qualified_names [Array<String>]
      # @param included_module_unqualified_names [Array<String>]
      # @param prepended_module_qualified_names [Array<String>]
      # @param prepended_module_unqualified_names [Array<String>]
      def initialize(
        extended_module_qualified_names: [],
        extended_module_unqualified_names: [],
        included_module_qualified_names: [],
        included_module_unqualified_names: [],
        prepended_module_qualified_names: [],
        prepended_module_unqualified_names: [],
        **keyword_arguments
      )
        super(**keyword_arguments)
        @extended_module_qualified_names = extended_module_qualified_names
        @extended_module_unqualified_names = extended_module_unqualified_names
        @included_module_qualified_names = included_module_qualified_names
        @included_module_unqualified_names = included_module_unqualified_names
        @prepended_module_qualified_names = prepended_module_qualified_names
        @prepended_module_unqualified_names = prepended_module_unqualified_names
      end

      # @param other [Rucoa::Definitions::ModuleDefinition]
      # @return [Rucoa::Definitions::ModuleDefinition]
      def merge!(other)
        self.extended_module_qualified_names |= other.extended_module_qualified_names
        self.extended_module_unqualified_names |= other.extended_module_unqualified_names
        self.included_module_qualified_names |= other.included_module_qualified_names
        self.included_module_unqualified_names |= other.included_module_unqualified_names
        self.prepended_module_qualified_names |= other.prepended_module_qualified_names
        self.prepended_module_unqualified_names |= other.prepended_module_unqualified_names
        self
      end
    end
  end
end
