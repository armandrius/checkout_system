# frozen_string_literal: true

class LineItem
  # TODO: don't let pricing rules be exposed as an array. Review attribute accessors
  attr_reader :checkout, :product, :quantity, :final_price, :pricing_rules_applied

  def initialize(product:, quantity: 1, checkout: nil)
    @checkout = checkout
    @product = product
    @quantity = quantity
    @final_price = product.price * quantity
    @pricing_rules_applied = []
  end

  def increment
    raise "Can't modify quantity because a pricing rule was applied" if pricing_rules_applied.any?

    @quantity += 1
    refresh_final_price
  end

  def decrement
    raise "Can't modify quantity because a pricing rule was applied" if pricing_rules_applied.any?

    @quantity = [0, @quantity - 1].max
    refresh_final_price
  end

  def apply_pricing_rule(pricing_rule)
    unless pricing_rule.is_a?(PricingRules::Base)
      raise ArgumentError,
            "Expected a pricing rule, got a #{pricing_rule.class} instead"
    end

    @final_price = pricing_rule.final_price(self)
    @pricing_rules_applied << pricing_rule
  end

  private

  def refresh_final_price
    @final_price = product.price * quantity
    quantity
  end
end
