# frozen_string_literal: true

module Rucoa
  module Nodes
    class BlockNode < Base
      include NodeConcerns::Body
      include NodeConcerns::Rescue

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
