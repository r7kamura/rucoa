# frozen_string_literal: true

require 'rbs'

module Rucoa
  module Rbs
    # Load definitions for Ruby core and standard libraries.
    class RubyDefinitionsLoader
      class << self
        # @return [Array<Rucoa::Definitions::Base>]
        def call
          new.call
        end
      end

      # @return [Array<Rucoa::Definitions::Base>]
      def call
        declarations.flat_map do |declaration|
          case declaration
          when ::RBS::AST::Declarations::Constant
            [ConstantDefinitionMapper.call(declaration: declaration)]
          when ::RBS::AST::Declarations::Class
            [ClassDefinitionMapper.call(declaration: declaration)] +
              declaration.members.grep(::RBS::AST::Members::MethodDefinition).map do |method_definition|
                MethodDefinitionMapper.call(
                  declaration: declaration,
                  method_definition: method_definition
                )
              end
          when ::RBS::AST::Declarations::Module
            [ModuleDefinitionMapper.call(declaration: declaration)] +
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

      # @return [Array<RBS::AST::Declarations::Class>]
      def class_declarations
        environment.class_decls.values.flat_map do |multi_entry|
          multi_entry.decls.map(&:decl)
        end
      end

      # @return [Array<RBS::AST::Declarations::Constant>]
      def constant_declarations
        environment.constant_decls.values.map(&:decl)
      end

      # @return [Array<RBS::AST::Declarations::Base>]
      def declarations
        class_declarations + constant_declarations
      end

      # @return [RBS::Environment]
      def environment
        @environment ||= ::RBS::Environment.from_loader(
          environment_loader
        ).resolve_type_names
      end

      # @return [RBS::EnvironmentLoader]
      def environment_loader
        loader = ::RBS::EnvironmentLoader.new
        ::RBS::Repository::DEFAULT_STDLIB_ROOT.children.sort.each do |pathname|
          loader.add(
            library: pathname.basename.to_s
          )
        end
        loader
      end
    end
  end
end
