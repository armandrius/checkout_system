# frozen_string_literal: true

module PricingRules
  class BulkFixedDiscount < Base
    attr_reader :min_quantity, :price

    def initialize(product:, min_quantity:, price:)
      super

      # TODO: assert quantity > 2, price < product.price
      @min_quantity = min_quantity
      @price = price
    end

    def final_price(line_item)
      return super if !product_matches?(line_item) || line_item.quantity < min_quantity

      line_item.quantity * price
    end
  end
end
