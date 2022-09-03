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

      # @return [Rucoa::Nodes::Base, nil]
      def parent
        @mutable_attributes[:parent]
      end

      # @param node [Rucoa::Nodes::Base]
      def parent=(node)
        @mutable_attributes[:parent] = node
      end

      # @return [Array<Rucoa::Nodes::Base>]
      def ancestors
        each_ancestor.to_a
      end

      # @return [Array<Rucoa::Nodes::Base>]
      def descendants
        each_descendant.to_a
      end

      # @param types [Array<Symbol>]
      # @return [Rucoa::Nodes::Base] if a block is given
      # @return [Enumerator] if no block is given
      def each_ancestor(*types, &block)
        return to_enum(__method__, *types) unless block

        visit_ancestors(types, &block)
        self
      end

      # @param types [Array<Symbol>]
      # @return [Rucoa::Nodes::Base] if a block is given
      # @return [Enumerator] if no block is given
      def each_child_node(*types, &block)
        return to_enum(__method__, *types) unless block

        visit_child_node(types, &block)
        self
      end

      # @param types [Array<Symbol>]
      # @return [Rucoa::Nodes::Base] if a block is given
      # @return [Enumerator] if no block is given
      def each_descendant(*types, &block)
        return to_enum(__method__, *types) unless block

        visit_descendants(types, &block)
        self
      end

      # @param position [Rucoa::Position]
      # @return [Boolean]
      def include_position?(position)
        return false unless location.expression

        Range.from_parser_range(location.expression).include?(position)
      end

      protected

      # Visit all descendants.
      # @param types [Array<Symbol>]
      # @return [void]
      def visit_descendants(types, &block)
        each_child_node(*types) do |child|
          yield(child)
          child.visit_descendants(types, &block)
        end
      end

      private

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
