# frozen_string_literal: true

module Rucoa
  module Nodes
    class ArgNode < Base
      # @return [String]
      # @example returns variable name
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       def foo(bar)
      #       end
      #     RUBY
      #     uri: 'file:///path/to/example.rb'
      #   ).node_at(
      #     Rucoa::Position.new(
      #       column: 8,
      #       line: 1
      #     )
      #   )
      #   expect(node.name).to eq('bar')
      def name
        children[0].to_s
      end
    end
  end
end
