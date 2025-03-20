# frozen_string_literal: true

class Checkout
  attr_reader :pricing_rules_list, :line_items_list

  def initialize(pricing_rules = [])
    @pricing_rules_list = CheckoutCollections::PricingRulesCollection.new(*pricing_rules)
    @line_items_list = CheckoutCollections::LineItemsCollection.new
  end

  def scan(*products)
    products.each do |product|
      line_items_list.append_product(product)
    end
  end

  # TODO: Empty basket
  def products
    line_items_list.products
  end

  # TODO: Multiple currencies mustn't be allowed
  def total
    line_items_list.apply_pricing_rules(pricing_rules_list)
    line_items_list.final_price
  end
end
