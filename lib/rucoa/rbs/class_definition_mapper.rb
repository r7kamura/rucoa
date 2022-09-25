# frozen_string_literal: true

module Rucoa
  module Rbs
    class ClassDefinitionMapper < ModuleDefinitionMapper
      # @return [Rucoa::Definitions::ClassDefinition]
      # @example supports `include`
      #   definition_store = Rucoa::DefinitionStore.new
      #   definition_store.bulk_add(Rucoa::DefinitionArchiver.load)
      #   subject = definition_store.find_definition_by_qualified_name('Array')
      #   expect(subject.included_module_qualified_names).to include('Enumerable')
      def call
        Definitions::ClassDefinition.new(
          description: description,
          extended_module_qualified_names: extended_module_qualified_names,
          included_module_qualified_names: included_module_qualified_names,
          location: location,
          prepended_module_qualified_names: prepended_module_qualified_names,
          qualified_name: qualified_name,
          super_class_qualified_name: super_class_qualified_name
        )
      end

      private

      # @return [String, nil]
      def super_class_qualified_name
        @declaration.super_class&.name&.to_s&.delete_prefix('::')
      end
    end
  end
end
