# frozen_string_literal: true

require 'debug'

module PricingRules
  class BulkFixedDiscount < Base
    include Concerns::BulkDiscountable

    attr_reader :price

    validates :price, Money

    def initialize(code:, product:, min_quantity:, price:)
      @min_quantity = min_quantity
      @price = price

      super
    end

    def final_price(line_item)
      return super unless applicable?(line_item)

      line_item.quantity * [price, line_item.product.price].min
    end
  end
end
