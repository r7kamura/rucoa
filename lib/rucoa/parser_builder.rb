# frozen_string_literal: true

require 'parser/current'

module Rucoa
  class ParserBuilder < ::Parser::Builders::Default
    NODE_CLASS_BY_TYPE = {
      str: Nodes::StrNode
    }.freeze

    # @note Override.
    def n(type, children, source_map)
      node_class_for(type).new(
        type,
        children,
        location: source_map
      )
    end

    private

    # @param type [Symbol]
    # @return [Class]
    def node_class_for(type)
      NODE_CLASS_BY_TYPE.fetch(type, Nodes::Base)
    end
  end
end
