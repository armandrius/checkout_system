# frozen_string_literal: true

class Checkout
  class PricingRulesList
    def initialize(checkout, *pricing_rules)
      # TODO: do we need the checkout?
      @checkout = checkout
      @indexed_pricing_rules = Hash.new { |hash, product_code| hash[product_code] = [] }
      pricing_rules.each { add(_1) }
    end

    def add(pricing_rule)
      assert_pricing_rule(pricing_rule)

      # TODO: check idempotency
      @indexed_pricing_rules[pricing_rule.product.code] << pricing_rule
    end

    def each(&)
      @indexed_pricing_rules.each(&)
    end

    private

    def assert_pricing_rule(rule)
      return if rule.is_a?(PricingRules::Base)

      raise ArgumentError, "Expected a pricing rule, got a #{rule.class} instead"
    end
  end

  class LineItemsList
    def initialize(checkout)
      @checkout = checkout
      @indexed_line_items = {}
    end

    def products
      @indexed_line_items.values.map(&:product)
    end

    def original_price
      @indexed_line_items.values.sum(&:price)
    end

    def final_price
      @indexed_line_items.values.sum(&:final_price)
    end

    def quantity(product)
      assert_product(product)

      @indexed_line_items[product.code]&.quantity || 0
    end

    def append_product(product)
      assert_product(product)

      if @indexed_line_items.key?(product.code)
        @indexed_line_items[product.code].increment
      else
        @indexed_line_items[product.code] = LineItem.new(product:, checkout: @checkout)
      end
    end

    def each(&)
      @indexed_line_items.values.each(&)
    end

    def apply_pricing_rules(pricing_rules_list)
      pricing_rules_list.each do |code, pricing_rules|
        next unless (line_item = @indexed_line_items[code])

        pricing_rules.each do |pricing_rule|
          line_item.apply_pricing_rule(pricing_rule)
        end
      end
    end

    private

    def assert_product(product)
      return if product.is_a?(Product)

      raise ArgumentError, "Expected a product, got a #{product.class} instead"
    end
  end

  attr_reader :pricing_rules_list, :line_items_list

  def initialize(pricing_rules = [])
    @pricing_rules_list = PricingRulesList.new(self, *pricing_rules)
    @line_items_list = LineItemsList.new(self)
  end

  def scan(*products)
    products.each do |product|
      line_items_list.append_product(product)
    end
  end

  def products
    line_items_list.products
  end

  def total
    # TODO: check idempotency
    line_items_list.apply_pricing_rules(pricing_rules_list)
    line_items_list.final_price
  end
end
