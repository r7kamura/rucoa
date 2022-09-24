# frozen_string_literal: true

module Rucoa
  class DefinitionStore
    def initialize
      @definition_by_qualified_name = {}
      @qualified_names_by_uri = ::Hash.new { |hash, key| hash[key] = [] }
    end

    # @return [String]
    def inspect
      "#<#{self.class} definitions_count=#{@definition_by_qualified_name.count}>"
    end

    # @param definitions [Array<Rucoa::Definition::Base>]
    # @return [void]
    def bulk_add(definitions)
      definitions.each do |definition|
        @qualified_names_by_uri[definition.location.uri] << definition.qualified_name if definition.location
        @definition_by_qualified_name[definition.qualified_name] = definition
      end
    end

    # @param source [Rucoa::Source]
    # @return [void]
    # @example resolves super class name from definitions
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
    #   definition = definition_store.find_definition_by_qualified_name('A::Bar')
    #   expect(definition.super_class_qualified_name).to eq('A::Foo')
    # @example resolves included module names from definitions
    #   definition_store = Rucoa::DefinitionStore.new
    #   foo = Rucoa::Source.new(
    #     content: <<~RUBY,
    #       module A
    #         module Foo
    #         end
    #       end
    #     RUBY
    #     uri: 'file:///path/to/a/foo.rb',
    #   )
    #   definition_store.update_from(foo)
    #   bar = Rucoa::Source.new(
    #     content: <<~RUBY,
    #       module A
    #         class Bar
    #           include Foo
    #         end
    #       end
    #     RUBY
    #     uri: 'file:///path/to/a/bar.rb',
    #   )
    #   definition_store.update_from(bar)
    #   definition = definition_store.find_definition_by_qualified_name('A::Bar')
    #   expect(definition.included_module_qualified_names).to eq(%w[A::Foo])
    def update_from(source)
      delete_definitions_in(source)
      add_definitions_in(source)
      resolve_constants_in(source)
    end

    # @param qualified_name [String]
    # @return [Rucoa::Definitions::Base, nil]
    def find_definition_by_qualified_name(qualified_name)
      @definition_by_qualified_name[qualified_name]
    end

    # @param method_name [String]
    # @param namespace [String]
    # @param singleton [Boolean]
    # @return [Rucoa::Definition::MethodDefinition, nil]
    # @example Supports inheritance
    #   source = Rucoa::Source.new(
    #     content: <<~RUBY,
    #       class A
    #         def foo
    #         end
    #       end
    #
    #       class B < A
    #       end
    #     RUBY
    #     uri: 'file:///path/to/example.rb'
    #   )
    #   definition_store = Rucoa::DefinitionStore.new
    #   definition_store.update_from(source)
    #   subject = definition_store.find_method_definition_by(
    #     method_name: 'foo',
    #     namespace: 'B',
    #     singleton: false
    #   )
    #   expect(subject.qualified_name).to eq('A#foo')
    # @example supports `include`
    #   source = Rucoa::Source.new(
    #     content: <<~RUBY,
    #       module A
    #         def foo
    #         end
    #       end
    #
    #       class B
    #         include A
    #       end
    #     RUBY
    #     uri: 'file:///path/to/example.rb'
    #   )
    #   definition_store = Rucoa::DefinitionStore.new
    #   definition_store.update_from(source)
    #   subject = definition_store.find_method_definition_by(
    #     method_name: 'foo',
    #     namespace: 'B',
    #     singleton: false
    #   )
    #   expect(subject.qualified_name).to eq('A#foo')
    # @example supports `prepend`
    #   source = Rucoa::Source.new(
    #     content: <<~RUBY,
    #       module A
    #         def foo
    #         end
    #       end
    #
    #       class B
    #         prepend A
    #
    #         def foo
    #         end
    #       end
    #     RUBY
    #     uri: 'file:///path/to/example.rb'
    #   )
    #   definition_store = Rucoa::DefinitionStore.new
    #   definition_store.update_from(source)
    #   subject = definition_store.find_method_definition_by(
    #     method_name: 'foo',
    #     namespace: 'B',
    #     singleton: false
    #   )
    #   expect(subject.qualified_name).to eq('A#foo')
    def find_method_definition_by(
      method_name:,
      namespace:,
      singleton: false
    )
      definition = find_definition_by_qualified_name(namespace)
      return unless definition

      ancestors_of(definition).find do |ancestor|
        method_marker = singleton ? '.' : '#'
        qualified_method_name = [
          ancestor.qualified_name,
          method_marker,
          method_name
        ].join
        method_definition = find_definition_by_qualified_name(qualified_method_name)
        break method_definition if method_definition
      end
    end

    # @param type [String]
    # @return [Array<Rucoa::Definitions::MethodDefinition>]
    # @example includes ancestors' methods
    #   definition_store = Rucoa::DefinitionStore.new
    #   definition_store.bulk_add(Rucoa::DefinitionArchiver.load)
    #   subject = definition_store.instance_method_definitions_of('File')
    #   expect(subject.map(&:qualified_name)).to include('IO#raw')
    # @example responds to `singleton<File>`
    #   definition_store = Rucoa::DefinitionStore.new
    #   definition_store.bulk_add(Rucoa::DefinitionArchiver.load)
    #   subject = definition_store.instance_method_definitions_of('singleton<File>')
    #   expect(subject.map(&:qualified_name)).to include('IO.write')
    def instance_method_definitions_of(type)
      singleton_class_name = singleton_class_name_from(type)
      return singleton_method_definitions_of(singleton_class_name) if singleton_class_name

      class_or_module_definition = find_definition_by_qualified_name(type)
      return [] unless class_or_module_definition

      method_definitions = instance_method_definitions
      ancestors_of(class_or_module_definition).flat_map do |ancestor|
        method_definitions.select do |method_definition|
          method_definition.namespace == ancestor.qualified_name
        end
      end
    end

    # @param type [String]
    # @return [Array<Rucoa::Definitions::MethodDefinition>]
    # @example returns singleton method definitions of File
    #   definition_store = Rucoa::DefinitionStore.new
    #   definition_store.bulk_add(Rucoa::DefinitionArchiver.load)
    #   subject = definition_store.singleton_method_definitions_of('File')
    #   expect(subject.map(&:qualified_name)).to include('IO.write')
    def singleton_method_definitions_of(type)
      class_or_module_definition = find_definition_by_qualified_name(type)
      return [] unless class_or_module_definition

      method_definitions = singleton_method_definitions
      ancestors_of(class_or_module_definition).flat_map do |ancestor|
        method_definitions.select do |method_definition|
          method_definition.namespace == ancestor.qualified_name
        end
      end
    end

    # @param namespace [String]
    # @return [Array<Rucoa::Definitions::ConstantDefinition>] e.g. File::Separator, File::SEPARATOR, etc.
    def constant_definitions_under(namespace)
      constant_definitions.select do |constant_definition|
        constant_definition.namespace == namespace
      end
    end

    # @param unqualified_name [Rucoa::UnqualifiedName]
    # @return [String]
    def resolve_constant(unqualified_name)
      (
        unqualified_name.module_nesting.map do |prefix|
          "#{prefix}::#{unqualified_name.chained_name}"
        end + [unqualified_name.chained_name]
      ).find do |candidate|
        find_definition_by_qualified_name(candidate)
      end || unqualified_name.chained_name
    end

    private

    # @param source [Rucoa::Source]
    # @return [void]
    def delete_definitions_in(source)
      @qualified_names_by_uri[source.uri].each do |qualified_name|
        @definition_by_qualified_name.delete(qualified_name)
      end
      @qualified_names_by_uri.delete(source.uri)
    end

    # @param type [String]
    # @return [String, nil]
    def singleton_class_name_from(type)
      type[/singleton<(\w+)>/, 1]
    end

    # @param definition [Rucoa::Definitions::Class, Rucoa::Definitions::Module]
    # @return [Array<Rucoa::Definitions::Class>] The classes and modules that are traced in method search (as `Module#ancestors` in Ruby)
    def ancestors_of(definition)
      if definition.is_a?(Rucoa::Definitions::ClassDefinition)
        [definition, *super_class_definitions_of(definition)]
      else
        [definition]
      end.flat_map do |base|
        module_ancestors_of(base)
      end
    end

    # @param definition [Rucoa::Definitions::Class, Rucoa::Definitions::Module]
    # @return [Array<Rucoa::Definitions::Class, Rucoa::Definitions::Module>] An array of prepended, itself, and included definitions
    def module_ancestors_of(definition)
      [
        *definition.prepended_module_qualified_names.filter_map do |qualified_name|
          find_definition_by_qualified_name(qualified_name)
        end.reverse,
        definition,
        *definition.included_module_qualified_names.filter_map do |qualified_name|
          find_definition_by_qualified_name(qualified_name)
        end.reverse
      ]
    end

    # @param definition [Rucoa::Definitions::Class]
    # @return [Array<Rucoa::Definitions::Class>] super "class"es (not including modules) in closest-first order
    def super_class_definitions_of(definition)
      result = []
      while (super_class_qualified_name = definition.super_class_qualified_name)
        super_definition = find_definition_by_qualified_name(super_class_qualified_name)
        break unless super_definition

        result << super_definition
        definition = super_definition
      end
      result
    end

    # @return [Array<Rucoa::Definitions::Base>]
    def definitions
      @definition_by_qualified_name.values
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

    # @return [Array<Rucoa::Definition::ConstantDefinition>]
    def constant_definitions
      definitions.grep(Definitions::ConstantDefinition)
    end

    # @param source [Rucoa::Source]
    # @return [void]
    def add_definitions_in(source)
      source.definitions.group_by do |definition|
        definition.location.uri
      end.each do |uri, definitions|
        @qualified_names_by_uri[uri] += definitions.map(&:qualified_name)
        definitions.each do |definition|
          @definition_by_qualified_name[definition.qualified_name] = definition
        end
      end
    end

    # @param source [Rucoa::Source]
    # @return [void]
    def resolve_constants_in(source)
      source.definitions.each do |definition|
        next unless definition.is_a?(Definitions::ClassDefinition)

        definition.super_class_qualified_name = resolve_constant(definition.super_class_unqualified_name)
        definition.included_module_qualified_names = definition.included_module_unqualified_names.map do |unqualified_name|
          resolve_constant(unqualified_name)
        end
        definition.prepended_module_qualified_names = definition.prepended_module_unqualified_names.map do |unqualified_name|
          resolve_constant(unqualified_name)
        end
      end
    end
  end
end
