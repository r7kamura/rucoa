# frozen_string_literal: true

require 'parser/current'

module Rucoa
  class ParserBuilder < ::Parser::Builders::Default
    NODE_CLASS_BY_TYPE = {
      arg: Nodes::ArgNode,
      args: Nodes::ArgsNode,
      begin: Nodes::BeginNode,
      block: Nodes::BlockNode,
      case: Nodes::CaseNode,
      casgn: Nodes::CasgnNode,
      cbase: Nodes::CbaseNode,
      class: Nodes::ClassNode,
      const: Nodes::ConstNode,
      csend: Nodes::SendNode,
      cvar: Nodes::CvarNode,
      cvasgn: Nodes::CvasgnNode,
      def: Nodes::DefNode,
      defs: Nodes::DefNode,
      ensure: Nodes::EnsureNode,
      for: Nodes::ForNode,
      gvar: Nodes::GvarNode,
      gvasgn: Nodes::GvasgnNode,
      if: Nodes::IfNode,
      ivar: Nodes::IvarNode,
      ivasgn: Nodes::IvasgnNode,
      kwbegin: Nodes::BeginNode,
      lvar: Nodes::LvarNode,
      lvasgn: Nodes::LvasgnNode,
      module: Nodes::ModuleNode,
      resbody: Nodes::ResbodyNode,
      rescue: Nodes::RescueNode,
      sclass: Nodes::SclassNode,
      send: Nodes::SendNode,
      str: Nodes::StrNode,
      super: Nodes::SendNode,
      sym: Nodes::SymNode,
      until: Nodes::UntilNode,
      when: Nodes::WhenNode,
      while: Nodes::WhileNode,
      zsuper: Nodes::SendNode
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
