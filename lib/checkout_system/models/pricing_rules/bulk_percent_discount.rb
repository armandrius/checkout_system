# frozen_string_literal: true

module PricingRules
  class BulkPercentDiscount < Base
    attr_reader :min_quantity, :discount_percentage

    def initialize(product:, min_quantity:, discount_percentage:)
      super

      @min_quantity = min_quantity
      @discount_percentage = discount_percentage

      validate_quantity
      validate_discount_percentage
    end

    def final_price(line_item)
      return super if !product_matches?(line_item) || line_item.quantity < min_quantity

      (product.price * line_item.quantity) * (1 - (discount_percentage / 100.0))
    end

    private

    def validate_quantity
      assert_class!(:min_quantity, min_quantity, Integer)
      raise ArgumentError, '"Min quantity" must greater than or equal to zero' unless min_quantity >= 0
    end

    def validate_discount_percentage
      assert_class!(:discount_percentage, discount_percentage, Numeric)
      raise ArgumentError, '"Discount percentage" must be between 0 and 100' unless discount_percentage.between?(0, 100)
    end
  end
end
