# frozen_string_literal: true

module Rucoa
  module Definitions
    # Represents class definition, module definition, or constant assignment.
    class ConstantDefinition < Base
      # @return [String]
      attr_reader :full_qualified_name

      # @return [String]
      attr_reader :source_path

      # @param full_qualified_name [String]
      # @param source_path [String]
      def initialize(full_qualified_name:, source_path:)
        super()
        @full_qualified_name = full_qualified_name
        @source_path = source_path
      end

      # @return [String]
      # @example returns non-full-qualified name
      #   definition = Rucoa::Definitions::ConstantDefinition.new(
      #     full_qualified_name: 'Foo::Bar::Baz',
      #     source_path: '/path/to/foo/bar/baz.rb'
      #   )
      #   expect(definition.name).to eq('Baz')
      def name
        names.last
      end

      # @return [String]
      # @example returns namespace
      #   definition = Rucoa::Definitions::ConstantDefinition.new(
      #     full_qualified_name: 'Foo::Bar::Baz',
      #     source_path: '/path/to/foo/bar/baz.rb'
      #   )
      #   expect(definition.namespace).to eq('Foo::Bar')
      def namespace
        names[..-2].join('::')
      end

      private

      # @return [Array<String>]
      def names
        @names ||= full_qualified_name.split('::')
      end
    end
  end
end
