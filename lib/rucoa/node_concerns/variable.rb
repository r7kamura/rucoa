# frozen_string_literal: true

module Rucoa
  module NodeConcerns
    module Variable
      # @return [String]
      # @example returns variable name
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       foo = 1
      #       foo
      #     RUBY
      #     uri: 'file:///path/to/example.rb'
      #   ).node_at(
      #     Rucoa::Position.new(
      #       column: 0,
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
