# frozen_string_literal: true

module Rucoa
  class NodeInspector
    # @param definition_store [Rucoa::DefinitionStore]
    # @param node [Rucoa::Node]
    def initialize(
      definition_store:,
      node:
    )
      @definition_store = definition_store
      @node = node
    end

    # @return [Array<Rucoa::Definitions::Base>]
    def definitions
      case @node
      when Nodes::ConstNode
        [constant_definition]
      when Nodes::SendNode
        method_definitions
      else
        []
      end
    end

    # @return [Array<Rucoa::Definitions::MethodDefinition>]
    def method_definitions
      method_receiver_types.flat_map do |type|
        @definition_store.instance_method_definitions_of(type)
      end.select do |method_definition|
        method_definition.method_name == @node.name
      end
    end

    # @return [Array<String>]
    def method_receiver_types
      return [] unless @node.is_a?(Nodes::SendNode)

      if @node.receiver
        self.class.new(
          definition_store: @definition_store,
          node: @node.receiver
        ).return_types
      else
        [@node.namespace]
      end
    end

    # @return [Array<String>]
    def return_types
      case @node.type
      when :const
        ["singleton<#{@node.name}>"]
      when :lvar
        return_types_for_lvar
      when :send
        return_types_for_send
      when :array
        %w[Array]
      when :class, :module, :nil
        %w[NilClass]
      when :complex
        %w[Complex]
      when :def, :sym
        %w[Symbol]
      when :dstr, :str, :xstr
        %w[String]
      when :erange, :irange
        %w[Range]
      when false
        %w[FalseClass]
      when :float
        %w[Float]
      when :hash, :pair
        %w[Hash]
      when :int
        %w[Integer]
      when :rational
        %w[Rational]
      when :regexp, :regopt
        %w[Regexp]
      when true
        %w[TrueClass]
      else
        []
      end
    end

    private

    # @return [Rucoa::Definitions::ConstantDefinition, nil]
    def constant_definition
      return unless @node.is_a?(Nodes::ConstNode)

      module_nesting = @node.module_nesting
      candidate_fully_qualified_names = module_nesting.flat_map do |module_nesting_fully_qualified_name|
        [
          module_nesting_fully_qualified_name
          # TODO: *ancestors_of(module_nesting_fully_qualified_name)
        ].map do |fully_qualified_name|
          [
            fully_qualified_name,
            @node.chained_name
          ].join('::')
        end
      end + [@node.chained_name]
      candidate_fully_qualified_names.find do |candidate_fully_qualified_name|
        definition = @definition_store.find_definition_by_fully_qualified_name(candidate_fully_qualified_name)
        break definition if definition
      end
    end

    # @return [Boolean]
    def singleton_method_call?
      @node.is_a?(Nodes::ConstNode)
    end

    # @return [String, nil]
    def nearest_def_fully_qualified_name
      @node.each_ancestor(:def).first&.fully_qualified_name
    end

    # @return [Array<String>]
    def return_types_for_lvar
      fully_qualified_name = nearest_def_fully_qualified_name
      return [] unless fully_qualified_name

      definition = @definition_store.find_definition_by_fully_qualified_name(fully_qualified_name)
      return [] unless definition

      definition.parameters.select do |parameter|
        parameter.name == @node.name
      end.flat_map(&:types)
    end

    # @return [Array<String>]
    def return_types_for_send
      method_receiver_types.flat_map do |type|
        @definition_store.find_method_definition_by(
          method_name: @node.name,
          namespace: type,
          singleton: singleton_method_call?
        )&.return_types
      end.compact
    end
  end
end
