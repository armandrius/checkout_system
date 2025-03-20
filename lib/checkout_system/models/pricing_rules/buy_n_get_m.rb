# frozen_string_literal: true

module PricingRules
  class BuyNGetM < Base
    attr_reader :buy, :get

    def initialize(product:, buy:, get:)
      super

      @buy = buy
      @get = get

      validate_buy
      validate_get
      validate_buy_and_get
    end

    def quantity_to_pay(quantity)
      complete_groups, incomplete_group = quantity.divmod(buy + get)
      (complete_groups * buy) + [incomplete_group, buy].min
    end

    def final_price(line_item)
      quantity = line_item.quantity
      return super if !product_matches?(line_item) || quantity < get

      line_item.product.price * quantity_to_pay(quantity)
    end

    private

    def validate_buy
      raise ArgumentError, '"Buy" must be a non-negative integer' unless buy.is_a?(Integer) && buy >= 0
    end

    def validate_get
      raise ArgumentError, '"Get" must be a non-negative integer' unless get.is_a?(Integer) && get >= 0
    end

    def validate_buy_and_get
      raise ArgumentError, 'The sum of "Buy" and "Get" must be greater than zero' unless (buy + get).positive?
    end
  end
end
