# frozen_string_literal: true

module Rucoa
  module Nodes
    class DefNode < Base
      # @return [String]
      # @example returns method name
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY
      #       module Foo
      #         class Bar
      #           def baz
      #           end
      #         end
      #       end
      #     RUBY
      #   ).node_at(
      #     Rucoa::Position.new(
      #       column: 4,
      #       line: 3
      #     )
      #   )
      #   expect(node.name).to eq('baz')
      def name
        children[0].to_s
      end

      # @return [String]
      # @example returns full qualified name
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY
      #       module Foo
      #         class Bar
      #           def baz
      #           end
      #         end
      #       end
      #     RUBY
      #   ).node_at(
      #     Rucoa::Position.new(
      #       column: 4,
      #       line: 3
      #     )
      #   )
      #   expect(node.fully_qualified_name).to eq('Foo::Bar#baz')
      def fully_qualified_name
        [
          namespace,
          method_marker,
          name
        ].join
      end

      # @return [Boolean]
      def singleton?
        each_ancestor(:sclass).any?
      end

      private

      # @return [String]
      def method_marker
        if singleton?
          '.'
        else
          '#'
        end
      end
    end
  end
end
