# frozen_string_literal: true

module Rucoa
  module Rbs
    class ClassDefinitionMapper
      class << self
        # @param declaration [RBS::AST::Declarations::Class]
        # @return [Rucoa::Definitions::ClassDefinition]
        def call(declaration:)
          new(declaration: declaration).call
        end
      end

      # @param declaration [RBS::AST::Declarations::Class]
      def initialize(declaration:)
        @declaration = declaration
      end

      # @return [Rucoa::Definitions::ClassDefinition]
      # @example supports `include`
      #   definition_store = Rucoa::DefinitionStore.new
      #   definition_store.bulk_add(Rucoa::DefinitionArchiver.load)
      #   subject = definition_store.find_definition_by_fully_qualified_name('Array')
      #   expect(subject.included_module_fully_qualified_names).to include('Enumerable')
      def call
        Definitions::ClassDefinition.new(
          description: description,
          fully_qualified_name: fully_qualified_name,
          included_module_fully_qualified_names: included_module_fully_qualified_names,
          location: location,
          prepended_module_fully_qualified_names: prepended_module_fully_qualified_names,
          super_class_fully_qualified_name: super_class_fully_qualified_name
        )
      end

      private

      # @return [String, nil]
      def description
        @declaration.comment&.string&.sub(/\A\s*<!--.*-->\s*/m, '')
      end

      # @return [String]
      def fully_qualified_name
        @declaration.name.to_s.delete_prefix('::')
      end

      # @return [Rucoa::Location]
      def location
        Location.from_rbs_location(@declaration.location)
      end

      # @return [Array<String>]
      def included_module_fully_qualified_names
        @declaration.members.filter_map do |member|
          case member
          when ::RBS::AST::Members::Include
            member.name.to_s.delete_prefix('::')
          end
        end
      end

      # @return [Array<String>]
      def prepended_module_fully_qualified_names
        @declaration.members.filter_map do |member|
          case member
          when ::RBS::AST::Members::Prepend
            member.name.to_s.delete_prefix('::')
          end
        end
      end

      # @return [String, nil]
      def super_class_fully_qualified_name
        @declaration.super_class&.name&.to_s&.delete_prefix('::')
      end
    end
  end
end
