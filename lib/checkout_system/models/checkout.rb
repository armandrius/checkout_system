# frozen_string_literal: true

class Checkout
  attr_reader :pricing_rules_list, :line_items_list

  def initialize(pricing_rules = [])
    @pricing_rules_list = CheckoutCollections::PricingRulesCollection.new
    add_pricing_rules(*pricing_rules)
    empty
  end

  def scan(*products)
    products.each do |product|
      line_items_list.append_product(product)
    end
  end

  def add_pricing_rules(*pricing_rules)
    pricing_rules.each do |pricing_rule|
      pricing_rules_list.add(pricing_rule)
    end
  end

  def products
    line_items_list.products
  end

  def empty
    @line_items_list = CheckoutCollections::LineItemsCollection.new
  end

  def total
    line_items_list.apply_pricing_rules(pricing_rules_list)
    line_items_list.final_price
  end
end
