# frozen_string_literal: true

module Rucoa
  module Nodes
    class ClassNode < Base
      include NodeConcerns::Body
      include NodeConcerns::NameFullyQualifiable

      # @return [String]
      def name
        const_node.name
      end

      # @return [String, nil]
      # @example returns nil for class for `class Foo`
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       class Foo
      #       end
      #     RUBY
      #     uri: 'file:///path/to/foo.rb'
      #   ).root_node
      #   expect(node.super_class_chained_name).to be_nil
      # @example returns "Bar" for class for `class Foo < Bar`
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       class Foo < Bar
      #       end
      #     RUBY
      #     uri: 'file:///path/to/foo.rb'
      #   ).root_node
      #   expect(node.super_class_chained_name).to eq('Bar')
      # @example returns "Bar::Baz" for class for `class Foo < Bar::Baz`
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       class Foo < Bar::Baz
      #       end
      #     RUBY
      #     uri: 'file:///path/to/foo.rb'
      #   ).root_node
      #   expect(node.super_class_chained_name).to eq('Bar::Baz')
      # @example returns "::Bar" for class for `class Foo < ::Bar`
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       class Foo < ::Bar
      #       end
      #     RUBY
      #     uri: 'file:///path/to/foo.rb'
      #   ).root_node
      #   expect(node.super_class_chained_name).to eq('::Bar')
      def super_class_chained_name
        return unless super_class_node.is_a?(Nodes::ConstNode)

        super_class_node.chained_name
      end

      private

      # @return [Rucoa::Nodes::ConstNode]
      def const_node
        children[0]
      end

      # @return [Rucoa::Nodes::Base, nil]
      def super_class_node
        children[1]
      end
    end
  end
end
