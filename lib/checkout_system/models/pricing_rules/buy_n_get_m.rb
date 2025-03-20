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
      assert_class!(:buy, buy, Integer)
      raise ArgumentError, '"Buy" must greater or equal to zero' unless buy >= 0
    end

    def validate_get
      assert_class!(:get, get, Integer)
      raise ArgumentError, '"Get" must greater or equal to zero' unless get >= 0
    end

    def validate_buy_and_get
      raise ArgumentError, 'The sum of "Buy" and "Get" must be greater than zero' unless (buy + get).positive?
    end
  end
end
