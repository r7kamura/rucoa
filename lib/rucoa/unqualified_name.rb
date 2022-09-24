# frozen_string_literal: true

module Rucoa
  UnqualifiedName = ::Struct.new(
    :chained_name,
    :module_nesting,
    keyword_init: true
  )
end
