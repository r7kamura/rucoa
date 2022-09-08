# frozen_string_literal: true

module Rucoa
  module DefinitionBuilders
    # Build Rucoa contant definition from RBS constant declaration.
    class RbsConstantDefinitionBuilder
      class << self
        # @param declaration [RBS::AST::Declarations::Constant]
        # @return [Rucoa::Definitions::ConstantDefinition]
        def call(declaration:)
          new(
            declaration: declaration
          ).call
        end
      end

      # @param declaration [RBS::AST::Declarations::Constant]
      # @return [Rucoa::Definitions::ConstantDefinition]
      def initialize(declaration:)
        @declaration = declaration
      end

      # @return [Rucoa::Definitions::ConstantDefinition]
      def call
        ::Rucoa::Definitions::ConstantDefinition.new(
          full_qualified_name: full_qualified_name,
          source_path: source_path
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
    end
  end
end
