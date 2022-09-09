# frozen_string_literal: true

require 'rbs'

module Rucoa
  class RbsDocumentLoader
    class << self
      def call
        new.call
      end
    end

    # @return [Array<Rucoa::Definitions::Base>]
    def call
      declarations.flat_map do |declaration|
        case declaration
        when ::RBS::AST::Declarations::Constant
          [
            DefinitionBuilders::RbsConstantDefinitionBuilder.call(declaration: declaration)
          ]
        when ::RBS::AST::Declarations::Class, ::RBS::AST::Declarations::Module
          declaration.members.grep(::RBS::AST::Members::MethodDefinition).map do |method_definition|
            DefinitionBuilders::RbsMethodDefinitionBuilder.call(
              declaration: declaration,
              method_definition: method_definition
            )
          end
        else
          []
        end
      end
    end

    private

    # @return [Array<RBS::AST::Declarations::Base>]
    def declarations
      ::RBS::Environment.from_loader(
        ::RBS::EnvironmentLoader.new
      ).resolve_type_names.declarations
    end
  end
end
