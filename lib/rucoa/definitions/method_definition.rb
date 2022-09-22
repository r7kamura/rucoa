# frozen_string_literal: true

module Rucoa
  module Definitions
    class MethodDefinition < Base
      # @return [String, nil]
      attr_reader :description

      # @return [Symbol]
      attr_reader :kind

      # @return [String]
      attr_reader :method_name

      # @return [String]
      attr_reader :namespace

      # @param description [String, nil]
      # @param kind [Symbol]
      # @param method_name [String]
      # @param namespace [String]
      # @param types [Array<Rucoa::Types::MethodType>]
      def initialize(
        description:,
        kind:,
        method_name:,
        namespace:,
        types:,
        **keyword_arguments
      )
        super(**keyword_arguments)
        @description = description
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
      #   expect(definition.fully_qualified_name).to eq('Foo::Bar#foo')
      def fully_qualified_name
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
            '%<fully_qualified_name>s(%<parameters>s) -> %<return_types>s',
            fully_qualified_name: fully_qualified_name,
            parameters: type.parameters_string,
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
