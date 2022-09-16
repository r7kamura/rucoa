# frozen_string_literal: true

module Rucoa
  module Rbs
    class ClassDefinitionMapper
      class << self
        # @param declaration [RBS::AST::Declarations::Class]
        # @return [Rucoa::Definitions::ClassDefinition]
        def call(declaration:)
          new(declaration: declaration).call
        end
      end

      # @param declaration [RBS::AST::Declarations::Class]
      def initialize(declaration:)
        @declaration = declaration
      end

      # @return [Rucoa::Definitions::ClassDefinition]
      def call
        Definitions::ClassDefinition.new(
          full_qualified_name: full_qualified_name,
          source_path: source_path,
          super_class_name: super_class_name
        )
      end

      private

      # @return [String]
      def full_qualified_name
        @declaration.name.to_s.delete_prefix('::')
      end

      # @return [String]
      def source_path
        @declaration.location.name
      end

      # @return [String, nil]
      def super_class_name
        @declaration.super_class&.name&.to_s&.delete_prefix('::')
      end
    end
  end
end
