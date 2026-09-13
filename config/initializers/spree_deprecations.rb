# spree_legacy_product_properties 1.0.1 (latest release) still defines its with_property* scopes via the
# deprecated Spree::Product.add_search_scope. We can't change that call, so drop only that message and
# keep every other Spree deprecation. Remove once the gem is updated or properties move to metafields
# (add_search_scope is removed in Spree 6.0).
silenced_spree_deprecations = [/\Aadd_search_scope is deprecated/].freeze
spree_deprecation_behaviors = Spree::Deprecation.behavior

Spree::Deprecation.behavior = lambda do |message, callstack, deprecator|
  next if silenced_spree_deprecations.any? { |pattern| message.to_s.sub(/\ADEPRECATION WARNING: /, '').match?(pattern) }

  spree_deprecation_behaviors.each { |behavior| behavior.call(message, callstack, deprecator) }
end
