# frozen_string_literal: true

class LineItem
  include Concerns::Validatable

  class ImmutableQuantityError < StandardError
    def message = 'Quantity is immutable because a pricing rule was applied'
  end

  attr_reader :product, :quantity, :final_price

  def initialize(product:, quantity: 1)
    @product = product
    @quantity = quantity
    @final_price = product.price * quantity
    @pricing_rules_applied = []
  end

  def pricing_rules_applied = @pricing_rules_applied.dup

  def increment
    immutable!

    @quantity += 1
    refresh_final_price
  end

  def decrement
    immutable!

    @quantity = [0, @quantity - 1].max
    refresh_final_price
  end

  def apply_pricing_rule(pricing_rule)
    assert_class!(:pricing_rule, pricing_rule, PricingRules::Base)

    @final_price = pricing_rule.final_price(self)
    @pricing_rules_applied << pricing_rule
  end

  private

  def immutable!
    raise ImmutableQuantityError if pricing_rules_applied.any?
  end

  def refresh_final_price
    @final_price = product.price * quantity
    quantity
  end
end
