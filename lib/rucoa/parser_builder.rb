# frozen_string_literal: true

require 'parser/current'

module Rucoa
  class ParserBuilder < ::Parser::Builders::Default
    NODE_CLASS_BY_TYPE = {
      begin: Nodes::BeginNode,
      casgn: Nodes::CasgnNode,
      cbase: Nodes::CbaseNode,
      class: Nodes::ClassNode,
      const: Nodes::ConstNode,
      def: Nodes::DefNode,
      defs: Nodes::DefsNode,
      lvar: Nodes::LvarNode,
      module: Nodes::ModuleNode,
      sclass: Nodes::SclassNode,
      send: Nodes::SendNode,
      str: Nodes::StrNode,
      sym: Nodes::SymNode
    }.freeze

    class << self
      # @param type [Symbol]
      # @return [Class]
      def node_class_for(type)
        NODE_CLASS_BY_TYPE.fetch(type, Nodes::Base)
      end
    end

    # @note Override.
    def n(
      type,
      children,
      source_map
    )
      self.class.node_class_for(type).new(
        type,
        children,
        location: source_map
      )
    end
  end
end
