# frozen_string_literal: true

module Rucoa
  module Definitions
    class MethodDefinition < Base
      # @return [String, nil]
      attr_reader :description

      # @return [String]
      attr_reader :method_name

      # @return [String]
      attr_reader :namespace

      # @return [String]
      attr_reader :source_path

      # @param description [String, nil]
      # @param kind [Symbol]
      # @param method_name [String]
      # @param namespace [String]
      # @param source_path [String]
      # @param types [Array<Rucoa::Types::MethodType>]
      def initialize(
        description:,
        kind:,
        method_name:,
        namespace:,
        source_path:,
        types:
      )
        super()
        @description = description
        @kind = kind
        @method_name = method_name
        @namespace = namespace
        @source_path = source_path
        @types = types
      end

      # @return [String]
      # @example returns qualified name of method
      #   method_definition = Rucoa::Definitions::MethodDefinition.new(
      #     description: nil,
      #     kind: :instance,
      #     method_name: 'foo',
      #     namespace: 'Foo::Bar',
      #     source_path: '/path/to/foo/bar.rb',
      #     types: []
      #   )
      #   expect(method_definition.full_qualified_name).to eq('Foo::Bar#foo')
      def full_qualified_name
        [
          @namespace,
          method_kind_symbol,
          @method_name
        ].join
      end

      # @todo
      # @return [Array<Rucoa::Definitions::MethodParameter>]
      def parameters
        []
      end

      # @return [Array<String>]
      # @example returns return types
      #   method_definition = Rucoa::Definitions::MethodDefinition.new(
      #     description: nil,
      #     kind: :instance,
      #     method_name: 'foo',
      #     namespace: 'Foo::Bar',
      #     source_path: '/path/to/foo/bar.rb',
      #     types: [
      #       Rucoa::Types::MethodType.new(
      #         parameters_string: '',
      #         return_type: 'String'
      #       )
      #     ]
      #   )
      #   expect(method_definition.return_types).to eq(%w[String])
      def return_types
        @types.map(&:return_type)
      end

      # @return [Array<String>]
      # @example returns signature
      #   method_definition = Rucoa::Definitions::MethodDefinition.new(
      #     description: nil,
      #     kind: :instance,
      #     method_name: 'foo',
      #     namespace: 'Foo::Bar',
      #     source_path: '/path/to/foo/bar.rb',
      #     types: [
      #       Rucoa::Types::MethodType.new(
      #         parameters_string: '?::int base',
      #         return_type: 'String'
      #       )
      #     ]
      #   )
      #   expect(method_definition.signatures).to eq(['Foo::Bar#foo(?::int base) -> String'])
      def signatures
        @types.map do |type|
          format(
            '%<full_qualified_name>s(%<parameters>s) -> %<return_types>s',
            full_qualified_name: full_qualified_name,
            parameters: type.parameters_string,
            return_types: type.return_type
          )
        end
      end

      private

      # @return [String]
      def method_kind_symbol
        case @kind
        when :instance
          '#'
        else
          '.'
        end
      end
    end
  end
end
