# frozen_string_literal: true

module Rucoa
  module Nodes
    class Base < ::Parser::AST::Node
      # @note Override.
      def initialize(...)
        # Necessary to assign before calling `super` because it may freeze itself depending on the case.
        @mutable_attributes = {}

        super
        children.each do |child|
          child.parent = self if child.is_a?(::Parser::AST::Node)
        end
      end

      # @return [Array<Rucoa::Nodes::Base>]
      def ancestors
        each_ancestor.to_a
      end

      # @return [Array<Rucoa::Nodes::Base>]
      def child_nodes
        each_child_node.to_a
      end

      # @return [Array<Rucoa::Nodes::Base>]
      def descendant_nodes
        each_descendant_node.to_a
      end

      # @param types [Array<Symbol>]
      # @return [Rucoa::Nodes::Base] if a block is given
      # @return [Enumerator] if no block is given
      def each_ancestor(
        *types,
        &block
      )
        return to_enum(__method__, *types) unless block

        visit_ancestors(types, &block)
        self
      end

      # @param types [Array<Symbol>]
      # @return [Rucoa::Nodes::Base] if a block is given
      # @return [Enumerator] if no block is given
      def each_child_node(
        *types,
        &block
      )
        return to_enum(__method__, *types) unless block

        visit_child_node(types, &block)
        self
      end

      # @param types [Array<Symbol>]
      # @return [Rucoa::Nodes::Base] if a block is given
      # @return [Enumerator] if no block is given
      def each_descendant_node(
        *types,
        &block
      )
        return to_enum(__method__, *types) unless block

        visit_descendant_nodes(types, &block)
        self
      end

      # @param position [Rucoa::Position]
      # @return [Boolean]
      def include_position?(position)
        return false unless location.expression

        Range.from_parser_range(location.expression).include?(position)
      end

      # @return [Array<String>]
      # @example return ["Bar::Foo", "Foo"] for class Foo::Bar::Baz
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       module Foo
      #         module Bar
      #           module Baz
      #           end
      #         end
      #       end
      #     RUBY
      #     uri: 'file:///path/to/foo/bar/baz.rb'
      #   ).node_at(
      #     Rucoa::Position.new(
      #       column: 4,
      #       line: 3
      #     )
      #   )
      #   expect(node.module_nesting).to eq(['Foo::Bar', 'Foo'])
      def module_nesting
        each_ancestor(:class, :module).map(&:qualified_name)
      end

      # @note namespace is a String representation of `Module.nesting`.
      # @return [String]
      # @example returns namespace
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
      #   expect(node.namespace).to eq('Foo::Bar')
      # @example returns "Object" when the node is not in a namespace
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       foo
      #     RUBY
      #     uri: 'file:///path/to/example.rb'
      #   ).root_node
      #   expect(node.namespace).to eq('Object')
      def namespace
        module_nesting.first || 'Object'
      end

      # @return [Array<Rucoa::Nodes::Base>]
      # @example returns next siblings
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       def foo
      #         a
      #         b
      #         c
      #         d
      #         e
      #       end
      #     RUBY
      #     uri: 'file:///path/to/example.rb'
      #   ).node_at(
      #     Rucoa::Position.new(
      #       column: 2,
      #       line: 4
      #     )
      #   )
      #   expect(node.next_sibling_nodes.map(&:name)).to eq(%w[d e])
      def next_sibling_nodes
        return [] unless parent

        parent.child_nodes[(sibling_node_index + 1)..]
      end

      # @return [Rucoa::Nodes::Base, nil]
      def parent
        @mutable_attributes[:parent]
      end

      # @param node [Rucoa::Nodes::Base]
      def parent=(node)
        @mutable_attributes[:parent] = node
      end

      # @return [Array<Rucoa::Nodes::Base>]
      # @example returns previous siblings
      #   node = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       def foo
      #         a
      #         b
      #         c
      #         d
      #         e
      #       end
      #     RUBY
      #     uri: 'file:///path/to/example.rb'
      #   ).node_at(
      #     Rucoa::Position.new(
      #       column: 2,
      #       line: 4
      #     )
      #   )
      #   expect(node.previous_sibling_nodes.map(&:name)).to eq(%w[a b])
      def previous_sibling_nodes
        return [] unless parent

        parent.child_nodes[0...sibling_node_index]
      end

      # @note Override.
      #   Some nodes change their type depending on the context.
      #   For example, `const` node can be `casgn` node.
      # @return [Rucoa::Nodes::Base]
      def updated(
        type = nil,
        children = nil,
        properties = {}
      )
        properties[:location] ||= @location
        ParserBuilder.node_class_for(type || @type).new(
          type || @type,
          children || @children,
          properties
        )
      end

      protected

      # Visit all descendant_nodes.
      # @param types [Array<Symbol>]
      # @return [void]
      def visit_descendant_nodes(
        types,
        &block
      )
        each_child_node do |child|
          yield(child) if types.empty? || types.include?(child.type)
          child.visit_descendant_nodes(types, &block)
        end
      end

      private

      # @return [Integer, nil]
      def sibling_node_index
        parent&.child_nodes&.index do |child|
          child.equal?(self)
        end
      end

      # Visits all ancestors.
      # @param types [Array<Symbol>]
      # @return [void]
      def visit_ancestors(types)
        current = self
        while (current = current.parent)
          next if !types.empty? && !types.include?(current.type)

          yield(current)
        end
      end

      # Visits all child nodes, excluding non Node instance.
      # @param types [Array<Symbol>]
      # @return [void]
      def visit_child_node(types)
        children.each do |child|
          next if !child.is_a?(::Parser::AST::Node) || (!types.empty? && !types.include?(child.type))

          yield(child)
        end
      end
    end
  end
end
