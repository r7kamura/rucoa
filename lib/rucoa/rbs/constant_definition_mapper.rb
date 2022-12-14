# frozen_string_literal: true

module Rucoa
  module Rbs
    class ConstantDefinitionMapper
      class << self
        # @param declaration [RBS::AST::Declarations::Constant]
        # @return [Rucoa::Definitions::ConstantDefinition]
        def call(declaration:)
          new(declaration: declaration).call
        end
      end

      # @param declaration [RBS::AST::Declarations::Constant]
      def initialize(declaration:)
        @declaration = declaration
      end

      # @return [Rucoa::Definitions::ConstantDefinition]
      def call
        Definitions::ConstantDefinition.new(
          description: description,
          location: location,
          qualified_name: qualified_name
        )
      end

      private

      # @return [String, nil]
      def description
        @declaration.comment&.string&.sub(/\A\s*<!--.*-->\s*/m, '')
      end

      # @return [Rucoa::Location]
      def location
        Location.from_rbs_location(@declaration.location)
      end

      # @return [String]
      def qualified_name
        @declaration.name.to_s.delete_prefix('::')
      end
    end
  end
end
