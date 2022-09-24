# frozen_string_literal: true

module Rucoa
  module Definitions
    class MethodDefinition < Base
      # @return [Symbol]
      attr_reader :kind

      # @return [String]
      attr_reader :method_name

      # @return [String]
      attr_reader :namespace

      # @param kind [Symbol]
      # @param method_name [String]
      # @param namespace [String]
      # @param types [Array<Rucoa::Types::MethodType>]
      def initialize(
        kind:,
        method_name:,
        namespace:,
        types:,
        **keyword_arguments
      )
        super(**keyword_arguments)
        @kind = kind
        @method_name = method_name
        @namespace = namespace
        @types = types
      end

      # @return [String]
      # @example returns qualified name of method
      #   definition = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       module Foo
      #         module Bar
      #           def foo
      #           end
      #         end
      #       end
      #     RUBY
      #     uri: 'file:///path/to/foo/bar/baz.rb',
      #   ).definitions[2]
      #   expect(definition.qualified_name).to eq('Foo::Bar#foo')
      def qualified_name
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
      #   definition = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       module Foo
      #         module Bar
      #           # @return [String]
      #           def baz
      #           end
      #         end
      #       end
      #     RUBY
      #     uri: 'file:///path/to/foo/bar.rb',
      #   ).definitions[2]
      #   expect(definition.return_types).to eq(%w[String])
      def return_types
        @types.map(&:return_type)
      end

      # @return [Array<String>]
      # @example returns signature
      #   definition = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       module Foo
      #         module Bar
      #           attr_writer :baz
      #         end
      #       end
      #     RUBY
      #     uri: 'file:///path/to/foo/bar.rb',
      #   ).definitions[2]
      #   expect(definition.signatures).to eq(
      #     [
      #       'Foo::Bar#baz=(value) -> Object'
      #     ]
      #   )
      def signatures
        @types.map do |type|
          format(
            '%<qualified_name>s(%<parameters>s) -> %<return_types>s',
            parameters: type.parameters_string,
            qualified_name: qualified_name,
            return_types: type.return_type
          )
        end
      end

      # @return [Boolean]
      def instance_method?
        @kind == :instance
      end

      # @return [Boolean]
      def singleton_method?
        !instance_method?
      end

      private

      # @return [String]
      def method_kind_symbol
        if instance_method?
          '#'
        else
          '.'
        end
      end
    end
  end
end
