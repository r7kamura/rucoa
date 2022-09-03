# frozen_string_literal: true

module Rucoa
  class SelectionRangeProvider
    class << self
      # @param source [Rucoa::Source]
      # @param position [Rucoa::Position]
      # @return [Hash, nil]
      def call(position:, source:)
        new(
          position: position,
          source: source
        ).call
      end
    end

    # @param position [Rucoa::Position]
    # @param source [Rucoa::Source]
    def initialize(position:, source:)
      @position = position
      @source = source
    end

    # @return [Hash, nil]
    def call
      ranges.reverse.reduce(nil) do |result, range|
        {
          parent: result,
          range: range.to_vscode_range
        }
      end
    end

    private

    # @return [Rucoa::Nodes::Base, nil]
    def node_at_position
      if instance_variable_defined?(:@node_at_position)
        @node_at_position
      else
        @node_at_position = @source.node_at(@position)
      end
    end

    # @return [Array<Rucoa::Range>]
    def ranges
      return [] unless node_at_position

      [node_at_position, *node_at_position.ancestors].flat_map do |node|
        NodeToRangesMapper.call(node)
      end
    end

    class NodeToRangesMapper
      class << self
        # @param node [Rucoa::Nodes::Base]
        # @return [Array<Rucoa::Range>]
        def call(node)
          new(node).call
        end
      end

      # @param node [Rucoa::Nodes::Base]
      def initialize(node)
        @node = node
      end

      # @return [Array<Rucoa::Range>]
      def call
        case @node
        when Nodes::StrNode
          [
            inner_range,
            expression_range
          ]
        else
          []
        end
      end

      private

      # @return [Rucoa::Range]
      def inner_range
        Range.new(
          Position.from_parser_range_ending(@node.location.begin),
          Position.from_parser_range_beginning(@node.location.end)
        )
      end

      # @return [Rucoa::Range]
      def expression_range
        Range.from_parser_range(@node.location.expression)
      end
    end
  end
end
