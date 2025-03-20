# frozen_string_literal: true

module PricingRules
  class BulkPercentDiscount < Base
    attr_reader :min_quantity, :discount_percentage

    def initialize(product:, min_quantity:, discount_percentage:)
      super

      # TODO: validate
      @min_quantity = min_quantity
      @discount_percentage = discount_percentage
    end

    def final_price(line_item)
      return super if !product_matches?(line_item) || line_item.quantity < min_quantity

      (product.price * line_item.quantity) * (1 - (discount_percentage / 100.0))
    end
  end
end
