# frozen_string_literal: true

module Rucoa
  class Source
    # @return [String]
    attr_reader :content

    # @return [String]
    attr_reader :file_path

    # @param content [String]
    # @param file_path [String, nil]
    def initialize(content:, file_path: nil)
      @content = content
      @file_path = file_path
    end

    # @param position [Rucoa::Position]
    # @return [Rucoa::Nodes::Base, nil]
    def node_at(position)
      root_and_descendant_nodes.reverse.find do |node|
        node.include_position?(position)
      end
    end

    private

    # @return [Rucoa::Nodes::Base, nil]
    def root_node
      @root_node ||= Parser.call(@content)
    end

    # @return [Array<Rucoa::Nodes::Base>]
    def root_and_descendant_nodes
      return [] unless root_node

      [root_node, *root_node.descendants]
    end
  end
end
