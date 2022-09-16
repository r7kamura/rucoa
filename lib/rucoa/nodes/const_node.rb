# frozen_string_literal: true

module Rucoa
  module Nodes
    class ConstNode < Base
      # @return [String]
      # @example returns "A" for "A"
      #   node = Rucoa::Parser.call('A')
      #   expect(node.name).to eq('A')
      # @example returns "B" for "A::B"
      #   node = Rucoa::Parser.call('A::B')
      #   expect(node.name).to eq('B')
      def name
        children[1].to_s
      end

      # @return [String]
      # @example returns "A" for "A"
      #   node = Rucoa::Parser.call('A')
      #   expect(node.chained_name).to eq('A')
      # @example returns "A::B" for "A::B"
      #   node = Rucoa::Parser.call('A::B')
      #   expect(node.chained_name).to eq('A::B')
      def chained_name
        if receiver.is_a?(ConstNode)
          [
            receiver.chained_name,
            name
          ].join('::')
        else
          name
        end
      end

      private

      # @return [Rucoa::Nodes::Base, nil]
      def receiver
        children[0]
      end
    end
  end
end
