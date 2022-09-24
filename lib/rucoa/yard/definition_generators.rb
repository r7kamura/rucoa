# frozen_string_literal: true

module Rucoa
  module Yard
    module DefinitionGenerators
      autoload :AttributeReaderDefinitionGenerator, 'rucoa/yard/definition_generators/attribute_reader_definition_generator'
      autoload :AttributeWriterDefinitionGenerator, 'rucoa/yard/definition_generators/attribute_writer_definition_generator'
      autoload :Base, 'rucoa/yard/definition_generators/base'
      autoload :ClassDefinitionGenerator, 'rucoa/yard/definition_generators/class_definition_generator'
      autoload :ConstantAssignmentDefinitionGenerator, 'rucoa/yard/definition_generators/constant_assignment_definition_generator'
      autoload :MethodDefinitionGenerator, 'rucoa/yard/definition_generators/method_definition_generator'
      autoload :ModuleDefinitionGenerator, 'rucoa/yard/definition_generators/module_definition_generator'
    end
  end
end
