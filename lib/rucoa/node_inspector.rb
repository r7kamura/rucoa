# frozen_string_literal: true

require 'set'

module Rucoa
  class NodeInspector
    # @param definition_store [Rucoa::DefinitionStore]
    # @param node [Rucoa::Node]
    def initialize(definition_store:, node:)
      @definition_store = definition_store
      @node = node
    end

    # @return [Array<String>]
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

    # @return [Boolean]
    def singleton_method_call?
      @node.is_a?(Nodes::ConstNode)
    end

    # @return [String, nil]
    def nearest_def_full_qualified_name
      @node.each_ancestor(:def).first&.full_qualified_name
    end

    # @return [Array<String>]
    def return_types_for_lvar
      full_qualified_name = nearest_def_full_qualified_name
      return [] unless full_qualified_name

      @definition_store.select_by_full_qualified_name(full_qualified_name).flat_map do |definition|
        definition.parameters.select do |parameter|
          parameter.name == @node.name
        end.flat_map(&:types)
      end
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
