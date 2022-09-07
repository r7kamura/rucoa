# frozen_string_literal: true

module Rucoa
  module Nodes
    autoload :Base, 'rucoa/nodes/base'
    autoload :ClassNode, 'rucoa/nodes/class_node'
    autoload :CasgnNode, 'rucoa/nodes/casgn_node'
    autoload :ConstNode, 'rucoa/nodes/const_node'
    autoload :DefNode, 'rucoa/nodes/def_node'
    autoload :DefsNode, 'rucoa/nodes/defs_node'
    autoload :ModuleNode, 'rucoa/nodes/module_node'
    autoload :SclassNode, 'rucoa/nodes/sclass_node'
    autoload :SendNode, 'rucoa/nodes/send_node'
    autoload :StrNode, 'rucoa/nodes/str_node'
    autoload :SymNode, 'rucoa/nodes/sym_node'
  end
end
