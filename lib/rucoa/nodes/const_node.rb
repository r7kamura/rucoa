# frozen_string_literal: true

module Rucoa
  module Nodes
    class ConstNode < Base
      # @return [String]
      # @example returns "A" for "A"
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       A
      #     RUBY
      #     uri: 'file:///path/to/a.rb'
      #   ).root_node
      #   expect(node.name).to eq('A')
      # @example returns "B" for "A::B"
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       A::B
      #     RUBY
      #     uri: 'file:///path/to/a.rb'
      #   ).node_at(
      #     Rucoa::Position.new(
      #       column: 4,
      #       line: 1
      #     )
      #   )
      #   expect(node.name).to eq('B')
      def name
        children[1].to_s
      end

      # @return [String]
      # @example returns "A" for "A"
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       A
      #     RUBY
      #     uri: 'file:///path/to/a.rb'
      #   ).root_node
      #   expect(node.chained_name).to eq('A')
      # @example returns "A::B" for "A::B"
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       A::B
      #     RUBY
      #     uri: 'file:///path/to/a.rb'
      #   ).node_at(
      #     Rucoa::Position.new(
      #       column: 4,
      #       line: 1
      #     )
      #   )
      #   expect(node.chained_name).to eq('A::B')
      def chained_name
        case receiver
        when Nodes::CbaseNode
          [
            '',
            name
          ].join('::')
        when Nodes::ConstNode
          [
            receiver.chained_name,
            name
          ].join('::')
        else
          name
        end
      end

      # @return [Array<String>]
      # @example return ["Bar::Foo", "Foo"] for class Foo::Bar::Baz
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       module Foo
      #         module Bar
      #           module Baz
      #           end
      #         end
      #       end
      #     RUBY
      #     uri: 'file:///path/to/foo/bar/baz.rb'
      #   ).node_at(
      #     Rucoa::Position.new(
      #       column: 4,
      #       line: 3
      #     )
      #   )
      #   expect(node.module_nesting).to eq(['Foo::Bar', 'Foo'])
      def module_nesting
        each_ancestor(:class, :module).map(&:fully_qualified_name)
      end

      private

      # @return [Rucoa::Nodes::Base, nil]
      def receiver
        children[0]
      end
    end
  end
end
