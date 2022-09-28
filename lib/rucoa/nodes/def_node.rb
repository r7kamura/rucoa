# frozen_string_literal: true

module Rucoa
  module Nodes
    class DefNode < Base
      include NodeConcerns::Body
      include NodeConcerns::Rescue

      # @return [String]
      def method_marker
        if singleton?
          '.'
        else
          '#'
        end
      end

      # @return [String]
      # @example returns method name
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       module Foo
      #         class Bar
      #           def baz
      #           end
      #         end
      #       end
      #     RUBY
      #     uri: 'file:///path/to/foo/bar.rb'
      #   ).node_at(
      #     Rucoa::Position.new(
      #       column: 4,
      #       line: 3
      #     )
      #   )
      #   expect(node.name).to eq('baz')
      def name
        children[-3].to_s
      end

      # @return [String]
      # @example returns full qualified name
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       module Foo
      #         class Bar
      #           def baz
      #           end
      #         end
      #       end
      #     RUBY
      #     uri: 'file:///path/to/foo/bar.rb'
      #   ).node_at(
      #     Rucoa::Position.new(
      #       column: 4,
      #       line: 3
      #     )
      #   )
      #   expect(node.qualified_name).to eq('Foo::Bar#baz')
      def qualified_name
        [
          namespace,
          method_marker,
          name
        ].join
      end

      # @return [Boolean]
      def singleton?
        type == :defs || each_ancestor(:sclass).any?
      end
    end
  end
end
