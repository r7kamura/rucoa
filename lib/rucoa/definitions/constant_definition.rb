# frozen_string_literal: true

module Rucoa
  module Definitions
    # Represents class definition, module definition, or constant assignment.
    class ConstantDefinition < Base
      # @return [String]
      attr_reader :fully_qualified_name

      # @return [String]
      attr_reader :source_path

      # @param fully_qualified_name [String]
      # @param source_path [String]
      def initialize(
        fully_qualified_name:,
        source_path:
      )
        super()
        @fully_qualified_name = fully_qualified_name
        @source_path = source_path
      end

      # @return [String]
      # @example returns non-full-qualified name
      #   definition = Rucoa::Definitions::ConstantDefinition.new(
      #     fully_qualified_name: 'Foo::Bar::Baz',
      #     source_path: '/path/to/foo/bar/baz.rb'
      #   )
      #   expect(definition.name).to eq('Baz')
      def name
        names.last
      end

      # @return [String]
      # @example returns namespace
      #   definition = Rucoa::Definitions::ConstantDefinition.new(
      #     fully_qualified_name: 'Foo::Bar::Baz',
      #     source_path: '/path/to/foo/bar/baz.rb'
      #   )
      #   expect(definition.namespace).to eq('Foo::Bar')
      def namespace
        names[..-2].join('::')
      end

      private

      # @return [Array<String>]
      def names
        @names ||= fully_qualified_name.split('::')
      end
    end
  end
end
