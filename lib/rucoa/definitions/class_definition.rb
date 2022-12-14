# frozen_string_literal: true

module Rucoa
  module Definitions
    class ClassDefinition < ModuleDefinition
      # @return [String, nil]
      attr_accessor :super_class_qualified_name

      # @return [Rucoa::UnqualifiedName, nil]
      attr_accessor :super_class_unqualified_name

      # @param super_class_qualified_name [String, nil]
      # @param super_class_unqualified_name [Rucoa::UnqualifiedName, nil]
      def initialize(
        super_class_qualified_name: nil,
        super_class_unqualified_name: nil,
        **keyword_arguments
      )
        super(**keyword_arguments)
        @super_class_qualified_name = super_class_qualified_name
        @super_class_unqualified_name = super_class_unqualified_name
      end

      # @param other [Rucoa::Definitions::ClassDefinition]
      def merge!(other)
        self.super_class_qualified_name ||= other.super_class_qualified_name
        self.super_class_unqualified_name ||= other.super_class_unqualified_name
        super
      end
    end
  end
end
