# frozen_string_literal: true

module Rucoa
  class SelectionRangeProvider
    class << self
      # @param text [String]
      # @param position [Rucoa::Position]
      # @return [Array<Rucoa::Range>]
      def call(position:, text:)
        new(
          position: position,
          text: text
        ).call
      end
    end

    # @param position [Rucoa::Position]
    # @param text [String]
    def initialize(position:, text:)
      @position = position
      @text = text
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
        @node_at_position = source.node_at(@position)
      end
    end

    # @return [Array<Rucoa::Range>]
    def ranges
      return [] unless node_at_position

      [node_at_position, *node_at_position.ancestors].flat_map do |node|
        to_range(node)
      end
    end

    # @return [Rucoa::Source]
    def source
      Source.new(content: @text)
    end

    # @param node [Rucoa::Nodes::Base]
    # @return [Array<Rucoa::Range>]
    def to_range(node)
      case node
      when Nodes::StrNode
        [
          Range.new(
            Position.new(
              column: node.location.begin.last_column,
              line: node.location.begin.last_line
            ),
            Position.new(
              column: node.location.end.column,
              line: node.location.end.line
            )
          ),
          Range.from_parser_range(node.location.expression)
        ]
      else
        []
      end
    end
  end
end
