# frozen_string_literal: true

module Rucoa
  module NodeConcerns
    module Modifier
      # @return [Boolean]
      # @example returns true on modifier if node
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       1 if true
      #     RUBY
      #     uri: 'file:///path/to/example.rb'
      #   ).node_at(
      #     Rucoa::Position.new(
      #       column: 2,
      #       line: 1
      #     )
      #   )
      #   expect(node).to be_modifier
      # @example returns false on non-modifier if node
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       if true
      #         1
      #       end
      #     RUBY
      #     uri: 'file:///path/to/example.rb'
      #   ).root_node
      #   expect(node).not_to be_modifier
      def modifier?
        location.end.nil?
      end
    end
  end
end
