# frozen_string_literal: true

module CheckoutCollections
  class PricingRulesCollection
    include Concerns::Assertable

    def initialize(*pricing_rules)
      @indexed_pricing_rules = Hash.new { |hash, product_code| hash[product_code] = [] }
      pricing_rules.each { add(_1) }
    end

    def add(pricing_rule)
      assert_class!(:pricing_rule, pricing_rule, PricingRules::Base)

      # TODO: check idempotency
      @indexed_pricing_rules[pricing_rule.product.code] << pricing_rule
    end

    def each(&)
      @indexed_pricing_rules.each(&)
    end
  end
end
