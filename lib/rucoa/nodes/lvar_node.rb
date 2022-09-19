# frozen_string_literal: true

module Rucoa
  module Nodes
    class LvarNode < Base
      # @return [String]
      # @example returns local variable name
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       foo = 1
      #       foo
      #     RUBY
      #     uri: 'file:///path/to/example.rb'
      #   ).node_at(
      #     Rucoa::Position.new(
      #       column: 2,
      #       line: 2
      #     )
      #   )
      #   expect(node.name).to eq('foo')
      def name
        children[0].to_s
      end
    end
  end
end
