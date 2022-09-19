# frozen_string_literal: true

module Rucoa
  module Nodes
    class SendNode < Base
      # @return [Array<Rucoa::Nodes::Base>]
      # @example returns arguments
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       foo(bar, baz)
      #     RUBY
      #     uri: 'file:///path/to/example.rb'
      #   ).root_node
      #   expect(node.arguments.map(&:name)).to eq(
      #     %w[
      #       bar
      #       baz
      #     ]
      #   )
      def arguments
        children[2..]
      end

      # @return [String]
      # @example returns method name
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       foo(bar, baz)
      #     RUBY
      #     uri: 'file:///path/to/example.rb'
      #   ).root_node
      #   expect(node.name).to eq('foo')
      def name
        children[1].to_s
      end

      # @return [Rucoa::Nodes::Base, nil]
      # @example returns nil for receiver-less method call
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       foo(bar, baz)
      #     RUBY
      #     uri: 'file:///path/to/example.rb'
      #   ).root_node
      #   expect(node.receiver).to be_nil
      # @example returns receiver
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       foo.bar
      #     RUBY
      #     uri: 'file:///path/to/example.rb'
      #   ).node_at(
      #     Rucoa::Position.new(
      #       column: 4,
      #       line: 1
      #     )
      #   )
      #   expect(node.receiver).to be_a(Rucoa::Nodes::SendNode)
      def receiver
        children[0]
      end
    end
  end
end
