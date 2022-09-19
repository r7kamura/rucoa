# frozen_string_literal: true

module Rucoa
  class DefinitionStore
    # @return [Array<Rucoa::Definition::Base>]
    attr_accessor :definitions

    def initialize
      @definitions = []
    end

    # @param source [Rucoa::Source]
    # @return [void]
    # @example resolves super class name correctly by using existent definitions
    #   definition_store = Rucoa::DefinitionStore.new
    #   foo = Rucoa::Source.new(
    #     content: <<~RUBY,
    #       module A
    #         class Foo
    #         end
    #       end
    #     RUBY
    #     uri: 'file:///path/to/a/foo.rb',
    #   )
    #   definition_store.update_from(foo)
    #   bar = Rucoa::Source.new(
    #     content: <<~RUBY,
    #       module A
    #         class Bar < Foo
    #         end
    #       end
    #     RUBY
    #     uri: 'file:///path/to/a/bar.rb',
    #   )
    #   definition_store.update_from(bar)
    #   expect(definition_store.definitions.last.super_class_fully_qualified_name).to eq('A::Foo')
    def update_from(source)
      delete_definitions_defined_in(source.name)

      # Need to store definitions before super class resolution.
      @definitions += source.definitions

      source.definitions.each do |definition|
        next unless definition.is_a?(Definitions::ClassDefinition)
        next if definition.super_class_resolved?

        definition.super_class_fully_qualified_name = resolve_super_class_of(definition)
      end
    end

    # @param fully_qualified_name [String]
    # @return [Array<Rucoa::Definitions::Base>]
    def select_by_fully_qualified_name(fully_qualified_name)
      @definitions.select do |definition|
        definition.fully_qualified_name == fully_qualified_name
      end
    end

    # @param method_name [String]
    # @param namespace [String]
    # @param singleton [Boolean]
    # @return [Rucoa::Definition::MethodDefinition, nil]
    # @example has the ability to find `IO.write` from `File.write`
    #   definition_store = Rucoa::DefinitionStore.new
    #   definition_store.definitions += Rucoa::DefinitionArchiver.load
    #   subject = definition_store.find_method_definition_by(
    #     method_name: 'write',
    #     namespace: 'File',
    #     singleton: true
    #   )
    #   expect(subject.fully_qualified_name).to eq('IO.write')
    def find_method_definition_by(method_name:, namespace:, singleton: false)
      if singleton
        singleton_method_definitions_of(namespace)
      else
        instance_method_definitions_of(namespace)
      end.find do |method_definition|
        method_definition.method_name == method_name
      end
    end

    # @param type [String]
    # @return [Array<Rucoa::Definitions::MethodDefinition>]
    # @example includes ancestors' methods
    #   definition_store = Rucoa::DefinitionStore.new
    #   definition_store.definitions += Rucoa::DefinitionArchiver.load
    #   subject = definition_store.instance_method_definitions_of('File')
    #   expect(subject.map(&:fully_qualified_name)).to include('IO#raw')
    # @example responds to `singleton<File>`
    #   definition_store = Rucoa::DefinitionStore.new
    #   definition_store.definitions += Rucoa::DefinitionArchiver.load
    #   subject = definition_store.instance_method_definitions_of('singleton<File>')
    #   expect(subject.map(&:fully_qualified_name)).to include('IO.write')
    def instance_method_definitions_of(type)
      singleton_class_name = singleton_class_name_from(type)
      return singleton_method_definitions_of(singleton_class_name) if singleton_class_name

      class_or_module_definition = find_class_or_module_definition(type)
      return [] unless class_or_module_definition

      definitions = instance_method_definitions
      [
        class_or_module_definition,
        *ancestor_definitions_of(class_or_module_definition)
      ].map(&:fully_qualified_name).flat_map do |fully_qualified_type_name|
        definitions.select do |definition|
          definition.namespace == fully_qualified_type_name
        end
      end
    end

    # @param type [String]
    # @return [Array<Rucoa::Definitions::MethodDefinition>]
    # @example returns singleton method definitions of File
    #   definition_store = Rucoa::DefinitionStore.new
    #   definition_store.definitions += Rucoa::DefinitionArchiver.load
    #   subject = definition_store.singleton_method_definitions_of('File')
    #   expect(subject.map(&:fully_qualified_name)).to include('IO.write')
    def singleton_method_definitions_of(type)
      class_or_module_definition = find_class_or_module_definition(type)
      return [] unless class_or_module_definition

      definitions = singleton_method_definitions
      [
        class_or_module_definition,
        *ancestor_definitions_of(class_or_module_definition)
      ].map(&:fully_qualified_name).flat_map do |fully_qualified_type_name|
        definitions.select do |definition|
          definition.namespace == fully_qualified_type_name
        end
      end
    end

    # @return [Array<Rucoa::Definition::ConstantDefinition>]
    def constant_definitions
      @definitions.grep(Definitions::ConstantDefinition)
    end

    # @param namespace [String]
    # @return [Array<Rucoa::Definitions::ConstantDefinition>] e.g. File::Separator, File::SEPARATOR, etc.
    def constant_definitions_under(namespace)
      constant_definitions.select do |constant_definition|
        constant_definition.namespace == namespace
      end
    end

    private

    # @param type [String]
    # @return [String, nil]
    def singleton_class_name_from(type)
      type[/singleton<(\w+)>/, 1]
    end

    # @param class_or_module_definition [Rucoa::Definitions::Class, Rucoa::Definitions::Module]
    # @return [Array<Rucoa::Definitions::Class>]
    def ancestor_definitions_of(class_or_module_definition)
      return [] unless class_or_module_definition.is_a?(Definitions::ClassDefinition)

      result = []
      class_definition = class_or_module_definition
      while (super_class_fully_qualified_name = class_definition.super_class_fully_qualified_name)
        class_definition = find_class_or_module_definition(super_class_fully_qualified_name)
        break unless class_definition

        result << class_definition
      end
      result
    end

    # @param type [String]
    # @return [Rucoa::Definitions::Class, Rucoa::Definitions::Module, nil]
    def find_class_or_module_definition(type)
      @definitions.find do |definition|
        definition.fully_qualified_name == type
      end
    end

    # @return [Array<Rucoa::Definition::MethodDefinition>]
    def method_definitions
      @definitions.grep(Definitions::MethodDefinition)
    end

    # @return [Array<Rucoa::Definition::MethodDefinition>]
    def instance_method_definitions
      method_definitions.select(&:instance_method?)
    end

    # @return [Array<Rucoa::Definition::MethodDefinition>]
    def singleton_method_definitions
      method_definitions.select(&:singleton_method?)
    end

    # @param source_path [String]
    # @return [void]
    def delete_definitions_defined_in(source_path)
      @definitions.delete_if do |definition|
        definition.source_path == source_path
      end
    end

    # @param class_definition [Rucoa::Definitions::ClassDefinition]
    # @return [String]
    def resolve_super_class_of(class_definition)
      return 'Object' unless class_definition.super_class_chained_name

      candidates = class_definition.module_nesting.map do |chained_name|
        [
          chained_name,
          class_definition.super_class_chained_name
        ].join('::')
      end + [class_definition.super_class_chained_name]
      definition = @definitions.find do |element|
        candidates.find do |candidate|
          # FIXME: Iterating all of definitions is not efficient.
          #   Implement more efficient way to find definition by its name such as hash-table or so.
          element.fully_qualified_name == candidate
        end
      end
      if definition
        definition.fully_qualified_name
      else
        class_definition.super_class_chained_name
      end
    end
  end
end
