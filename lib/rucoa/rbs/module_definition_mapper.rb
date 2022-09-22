# frozen_string_literal: true

module Rucoa
  module Rbs
    class ModuleDefinitionMapper
      class << self
        # @param declaration [RBS::AST::Declarations::Module]
        # @return [Rucoa::Definitions::ModuleDefinition]
        def call(declaration:)
          new(declaration: declaration).call
        end
      end

      # @param declaration [RBS::AST::Declarations::Module]
      def initialize(declaration:)
        @declaration = declaration
      end

      # @return [Rucoa::Definitions::ModuleDefinition]
      def call
        Definitions::ModuleDefinition.new(
          fully_qualified_name: fully_qualified_name,
          location: location
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
    end
  end
end
