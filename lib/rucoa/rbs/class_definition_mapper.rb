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
          fully_qualified_name: fully_qualified_name,
          location: location,
          super_class_fully_qualified_name: super_class_fully_qualified_name
        )
      end

      private

      # @return [String]
      def fully_qualified_name
        @declaration.name.to_s.delete_prefix('::')
      end

      # @return [Rucoa::Location]
      def location
        Location.from_rbs_location(@declaration.location)
      end

      # @return [String, nil]
      def super_class_fully_qualified_name
        @declaration.super_class&.name&.to_s&.delete_prefix('::')
      end
    end
  end
end
