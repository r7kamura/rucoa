# frozen_string_literal: true

module Rucoa
  class DefinitionStore
    def initialize
      @definition_by_full_qualified_name = {}
      @fully_qualified_names_by_uri = ::Hash.new { |hash, key| hash[key] = [] }
    end

    # @param definitions [Array<Rucoa::Definition::Base>]
    # @return [void]
    def bulk_add(definitions)
      definitions.each do |definition|
        @fully_qualified_names_by_uri["file://#{definition.source_path}"] << definition.fully_qualified_name
        @definition_by_full_qualified_name[definition.fully_qualified_name] = definition
      end
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
    #   definition = definition_store.find_definition_by_fully_qualified_name('A::Bar')
    #   expect(definition.super_class_fully_qualified_name).to eq('A::Foo')
    def update_from(source)
      delete_definitions_about(source)

      # Need to store definitions before super class resolution.
      source.definitions.group_by(&:source_path).each do |source_path, definitions|
        @fully_qualified_names_by_uri["file://#{source_path}"] += definitions.map(&:fully_qualified_name)
        definitions.each do |definition|
          @definition_by_full_qualified_name[definition.fully_qualified_name] = definition
        end
      end

      source.definitions.each do |definition|
        next unless definition.is_a?(Definitions::ClassDefinition)
        next if definition.super_class_resolved?

        definition.super_class_fully_qualified_name = resolve_super_class_of(definition)
      end
    end

    # @param fully_qualified_name [String]
    # @return [Rucoa::Definitions::Base, nil]
    def find_definition_by_fully_qualified_name(fully_qualified_name)
      @definition_by_full_qualified_name[fully_qualified_name]
    end

    # @param method_name [String]
    # @param namespace [String]
    # @param singleton [Boolean]
    # @return [Rucoa::Definition::MethodDefinition, nil]
    # @example has the ability to find `IO.write` from `File.write`
    #   definition_store = Rucoa::DefinitionStore.new
    #   definition_store.bulk_add(Rucoa::DefinitionArchiver.load)
    #   subject = definition_store.find_method_definition_by(
    #     method_name: 'write',
    #     namespace: 'File',
    #     singleton: true
    #   )
    #   expect(subject.fully_qualified_name).to eq('IO.write')
    def find_method_definition_by(method_name:, namespace:, singleton: false)
      definition = find_definition_by_fully_qualified_name(namespace)
      return unless definition

      [
        namespace,
        *ancestor_definitions_of(definition).map(&:fully_qualified_name)
      ].find do |fully_qualified_name|
        method_marker = singleton ? '.' : '#'
        fully_qualified_method_name = [
          fully_qualified_name,
          method_marker,
          method_name
        ].join
        definition = find_definition_by_fully_qualified_name(fully_qualified_method_name)
        break definition if definition
      end
    end

    # @param type [String]
    # @return [Array<Rucoa::Definitions::MethodDefinition>]
    # @example includes ancestors' methods
    #   definition_store = Rucoa::DefinitionStore.new
    #   definition_store.bulk_add(Rucoa::DefinitionArchiver.load)
    #   subject = definition_store.instance_method_definitions_of('File')
    #   expect(subject.map(&:fully_qualified_name)).to include('IO#raw')
    # @example responds to `singleton<File>`
    #   definition_store = Rucoa::DefinitionStore.new
    #   definition_store.bulk_add(Rucoa::DefinitionArchiver.load)
    #   subject = definition_store.instance_method_definitions_of('singleton<File>')
    #   expect(subject.map(&:fully_qualified_name)).to include('IO.write')
    def instance_method_definitions_of(type)
      singleton_class_name = singleton_class_name_from(type)
      return singleton_method_definitions_of(singleton_class_name) if singleton_class_name

      class_or_module_definition = find_definition_by_fully_qualified_name(type)
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
    #   definition_store.bulk_add(Rucoa::DefinitionArchiver.load)
    #   subject = definition_store.singleton_method_definitions_of('File')
    #   expect(subject.map(&:fully_qualified_name)).to include('IO.write')
    def singleton_method_definitions_of(type)
      class_or_module_definition = find_definition_by_fully_qualified_name(type)
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
      definitions.grep(Definitions::ConstantDefinition)
    end

    # @param namespace [String]
    # @return [Array<Rucoa::Definitions::ConstantDefinition>] e.g. File::Separator, File::SEPARATOR, etc.
    def constant_definitions_under(namespace)
      constant_definitions.select do |constant_definition|
        constant_definition.namespace == namespace
      end
    end

    private

    # @param source [Rucoa::Source]
    # @return [void]
    def delete_definitions_about(source)
      @fully_qualified_names_by_uri[source.uri].each do |fully_qualified_name|
        @definition_by_full_qualified_name.delete(fully_qualified_name)
      end
      @fully_qualified_names_by_uri.delete(source.uri)
    end

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
        class_definition = find_definition_by_fully_qualified_name(super_class_fully_qualified_name)
        break unless class_definition

        result << class_definition
      end
      result
    end

    # @return [Array<Rucoa::Definitions::Base>]
    def definitions
      @definition_by_full_qualified_name.values
    end

    # @return [Array<Rucoa::Definition::MethodDefinition>]
    def method_definitions
      definitions.grep(Definitions::MethodDefinition)
    end

    # @return [Array<Rucoa::Definition::MethodDefinition>]
    def instance_method_definitions
      method_definitions.select(&:instance_method?)
    end

    # @return [Array<Rucoa::Definition::MethodDefinition>]
    def singleton_method_definitions
      method_definitions.select(&:singleton_method?)
    end

    # @param class_definition [Rucoa::Definitions::ClassDefinition]
    # @return [String]
    def resolve_super_class_of(class_definition)
      return 'Object' unless class_definition.super_class_chained_name

      class_definition.super_class_candidates.find do |candidate|
        find_definition_by_fully_qualified_name(candidate)
      end || class_definition.super_class_chained_name
    end
  end
end
