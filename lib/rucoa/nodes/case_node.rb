# frozen_string_literal: true

module Rucoa
  module Nodes
    class CaseNode < Base
      # @return [Array<Rucoa::Nodes::Base>]
      # @example returns when nodes
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       case foo
      #       when 1
      #       when 2
      #       else
      #       end
      #     RUBY
      #     uri: 'file:///foo.rb'
      #   ).root_node
      #   expect(node.whens.length).to eq(2)
      def whens
        children[1...-1]
      end
    end
  end
end
