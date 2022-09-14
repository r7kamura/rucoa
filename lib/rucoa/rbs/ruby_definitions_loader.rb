# frozen_string_literal: true

require 'rbs'

module Rucoa
  module Rbs
    # Load definitions from RBS's definitions about Ruby core and its standard libraries.
    class RubyDefinitionsLoader
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
              ConstantDefinitionMapper.call(declaration: declaration)
            ]
          when ::RBS::AST::Declarations::Class, ::RBS::AST::Declarations::Module
            declaration.members.grep(::RBS::AST::Members::MethodDefinition).map do |method_definition|
              MethodDefinitionMapper.call(
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
end
