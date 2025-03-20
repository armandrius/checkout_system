# frozen_string_literal: true

module CheckoutCollections
  class PricingRulesCollection
    include Concerns::Validatable

    def initialize
      @indexed_pricing_rules = Hash.new { |hash, product_code| hash[product_code] = [] }
    end

    def add(*pricing_rules)
      pricing_rules.each do |pricing_rule|
        assert_class!(:pricing_rule, pricing_rule, PricingRules::Base)

        rules_for_product = @indexed_pricing_rules[pricing_rule.product.code]

        next if rules_for_product.map(&:code).include?(pricing_rule.code)

        rules_for_product << pricing_rule
      end
    end

    def each(&)
      @indexed_pricing_rules.each(&)
    end
  end
end
