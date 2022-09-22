# frozen_string_literal: true

module Rucoa
  Location = ::Struct.new(
    :range,
    :uri,
    keyword_init: true
  ) do
    class << self
      # @param location [RBS::Location]
      # @return [Rucoa::Location]
      def from_rbs_location(location)
        new(
          range: Range.new(
            Position.new(
              column: location.start_column,
              line: location.start_line
            ),
            Position.new(
              column: location.end_column,
              line: location.end_line
            )
          ),
          uri: "file://#{location.name}"
        )
      end

      # @param node [Rucoa::Nodes::Base]
      def from_rucoa_node(node)
        new(
          range: Range.from_parser_range(node.location.expression),
          uri: node.location.expression.source_buffer.name
        )
      end
    end
  end
end
