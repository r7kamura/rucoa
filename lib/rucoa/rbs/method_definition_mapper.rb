# frozen_string_literal: true

module Rucoa
  module Rbs
    class MethodDefinitionMapper
      class << self
        # @param declaration [RBS::AST::Declarations::Class, RBS::AST::Declarations::Module]
        # @param method_definition [RBS::AST::Members::MethodDefinition]
        # @return [Rucoa::Definitions::MethodDefinition]
        def call(
          declaration:,
          method_definition:
        )
          new(
            declaration: declaration,
            method_definition: method_definition
          ).call
        end
      end

      # @param declaration [RBS::AST::Declarations::Class, RBS::AST::Declarations::Module]
      # @param method_definition [RBS::AST::Members::MethodDefinition]
      def initialize(
        declaration:,
        method_definition:
      )
        @declaration = declaration
        @method_definition = method_definition
      end

      # @return [Rucoa::Definitions::MethodDefinition]
      def call
        Definitions::MethodDefinition.new(
          description: description,
          kind: kind,
          method_name: method_name,
          namespace: namespace,
          source_path: source_path,
          types: types
        )
      end

      private

      # @return [Array<Rucoa::Types::MethodType>]
      def types
        @method_definition.types.map do |method_type|
          MethodTypeMapper.call(
            method_type: method_type
          )
        end
      end

      # @return [String, nil]
      def description
        @method_definition.comment&.string&.sub(/\A\s*<!--.*-->\s*/m, '')
      end

      # @return [String]
      def namespace
        @declaration.name.to_s.delete_prefix('::')
      end

      # @return [String]
      def method_name
        @method_definition.name.to_s
      end

      # @return [Symbol]
      def kind
        @method_definition.kind
      end

      # @return [String]
      def source_path
        @declaration.location.name
      end

      class MethodTypeMapper
        class << self
          # @param method_type [RBS::Types::MethodType]
          # @return [Rucoa::Types::MethodType]
          def call(method_type:)
            new(method_type: method_type).call
          end

          # @param type [RBS::Types::Base]
          # @return [String]
          def stringify(type)
            type.to_s.delete_prefix('::')
          end
        end

        # @param method_type [RBS::Types::MethodType]
        def initialize(method_type:)
          @method_type = method_type
        end

        # @return [Rucoa::Types::MethodType]
        def call
          Types::MethodType.new(
            parameters_string: @method_type.type.param_to_s,
            return_type: self.class.stringify(@method_type.type.return_type)
          )
        end
      end
    end
  end
end
