# frozen_string_literal: true

module Rucoa
  class DefinitionStore
    # @return [Array<Rucoa::Definition::Base>]
    attr_accessor :definitions

    def initialize
      @definitions = []
    end

    # @param source_path [String]
    # @return [Array<Rucoa::Definition::Base>]
    def update_definitions_defined_in(source_path, definitions:)
      delete_definitions_defined_in(source_path)
      @definitions += definitions
    end

    # @param full_qualified_name [String]
    # @return [Array<Rucoa::Definitions::Base>]
    def select_by_full_qualified_name(full_qualified_name)
      @definitions.select do |definition|
        definition.full_qualified_name == full_qualified_name
      end
    end

    # @param namespace [String]
    # @return [Array<Rucoa::Definitions::MethodDefinition>]
    def method_definitions_of(namespace)
      method_definitions.select do |method_definition|
        method_definition.namespace == namespace
      end
    end

    # @param namespace [String]
    # @return [Array<Rucoa::Definitions::ConstantDefinition>] e.g. File::Separator, File::SEPARATOR, etc.
    def constant_definitions_under(namespace)
      constant_definitions.select do |constant_definition|
        constant_definition.namespace == namespace
      end
    end

    private

    # @return [Array<Rucoa::Definition::ConstantDefinition>]
    def constant_definitions
      @definitions.grep(Definitions::ConstantDefinition)
    end

    # @return [Array<Rucoa::Definition::MethodDefinition>]
    def method_definitions
      @definitions.grep(Definitions::MethodDefinition)
    end

    # @param source_path [String]
    # @return [Array<Rucoa::Definition::Base>]
    def delete_definitions_defined_in(source_path)
      @definitions.delete_if do |definition|
        definition.source_path == source_path
      end
    end
  end
end
