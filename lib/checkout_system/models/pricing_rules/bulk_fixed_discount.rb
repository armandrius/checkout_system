# frozen_string_literal: true

require 'debug'

module PricingRules
  class BulkFixedDiscount < Base
    attr_reader :min_quantity, :price

    def initialize(product:, min_quantity:, price:)
      super

      @min_quantity = min_quantity
      @price = price

      validate_price
      validate_quantity
    end

    def final_price(line_item)
      return super if !product_matches?(line_item) || line_item.quantity < min_quantity

      line_item.quantity * [price, line_item.product.price].min
    end

    private

    def validate_price
      assert_class!(:price, price, Money)
    end

    def validate_quantity
      assert_class!(:min_quantity, min_quantity, Integer)
      raise ArgumentError, '"Min quantity" must be greater than or equal to zero' unless min_quantity >= 0
    end
  end
end
