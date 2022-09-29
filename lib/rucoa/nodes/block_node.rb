# frozen_string_literal: true

module Rucoa
  module Nodes
    class BlockNode < Base
      include NodeConcerns::Body
      include NodeConcerns::Rescue

      # @return [Array<Rucoa::Nodes::ArgNode>]
      # @example returns arguments
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       foo do |bar, baz|
      #       end
      #     RUBY
      #     uri: 'file:///path/to/example.rb'
      #   ).root_node
      #   expect(node.arguments.map(&:name)).to eq(%w[bar baz])
      def arguments
        children[-2]
      end

      # @return [Rucoa::Nodes::SendNode]
      # @example returns send node
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       foo do
      #       end
      #     RUBY
      #     uri: 'file:///foo.rb'
      #   ).root_node
      #   expect(node.send_node.name).to eq('foo')
      def send_node
        children[0]
      end
    end
  end
end
