# frozen_string_literal: true

module Rucoa
  module Definitions
    # Represents class definition, module definition, or constant assignment.
    class ConstantDefinition < Base
      # @return [String]
      attr_reader :fully_qualified_name

      # @param fully_qualified_name [String]
      def initialize(
        fully_qualified_name:,
        **keyword_arguments
      )
        super(**keyword_arguments)
        @fully_qualified_name = fully_qualified_name
      end

      # @return [String]
      # @example returns non-full-qualified name
      #   definition = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       module Foo
      #         module Bar
      #           class Baz
      #           end
      #         end
      #       end
      #     RUBY
      #     uri: 'file:///path/to/foo/bar/baz.rb',
      #   ).definitions[2]
      #   expect(definition.name).to eq('Baz')
      def name
        names.last
      end

      # @return [String]
      # @example returns namespace
      #   definition = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       module Foo
      #         module Bar
      #           class Baz
      #           end
      #         end
      #       end
      #     RUBY
      #     uri: 'file:///path/to/foo/bar/baz.rb',
      #   ).definitions[2]
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
