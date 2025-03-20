# frozen_string_literal: true

module PricingRules
  class BulkPercentDiscount < Base
    include Concerns::BulkDiscountable

    attr_reader :discount_percentage

    validates(:discount_percentage, Numeric, 'must be between 0 and 100') { _1.between?(0, 100) }

    def initialize(code:, product:, min_quantity:, discount_percentage:)
      @min_quantity = min_quantity
      @discount_percentage = discount_percentage

      super
    end

    def final_price(line_item)
      return super unless applicable?(line_item)

      (product.price * line_item.quantity) * (1 - (discount_percentage / 100.0))
    end
  end
end
