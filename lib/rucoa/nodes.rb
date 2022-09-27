# frozen_string_literal: true

module Rucoa
  module Nodes
    autoload :Base, 'rucoa/nodes/base'
    autoload :BeginNode, 'rucoa/nodes/begin_node'
    autoload :BlockNode, 'rucoa/nodes/block_node'
    autoload :CaseNode, 'rucoa/nodes/case_node'
    autoload :CasgnNode, 'rucoa/nodes/casgn_node'
    autoload :CbaseNode, 'rucoa/nodes/cbase_node'
    autoload :ClassNode, 'rucoa/nodes/class_node'
    autoload :ConstNode, 'rucoa/nodes/const_node'
    autoload :DefNode, 'rucoa/nodes/def_node'
    autoload :EnsureNode, 'rucoa/nodes/ensure_node'
    autoload :ForNode, 'rucoa/nodes/for_node'
    autoload :IfNode, 'rucoa/nodes/if_node'
    autoload :LvarNode, 'rucoa/nodes/lvar_node'
    autoload :ModuleNode, 'rucoa/nodes/module_node'
    autoload :ResbodyNode, 'rucoa/nodes/resbody_node'
    autoload :RescueNode, 'rucoa/nodes/rescue_node'
    autoload :SclassNode, 'rucoa/nodes/sclass_node'
    autoload :SendNode, 'rucoa/nodes/send_node'
    autoload :StrNode, 'rucoa/nodes/str_node'
    autoload :SymNode, 'rucoa/nodes/sym_node'
    autoload :UntilNode, 'rucoa/nodes/until_node'
    autoload :WhenNode, 'rucoa/nodes/when_node'
    autoload :WhileNode, 'rucoa/nodes/while_node'
  end
end
