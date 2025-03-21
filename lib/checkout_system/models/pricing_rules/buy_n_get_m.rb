# frozen_string_literal: true

module PricingRules
  class BuyNGetM < Base
    attr_reader :buy, :get

    validates_non_negative_integer(:buy)
    validates_non_negative_integer(:get)

    def initialize(code:, product:, buy:, get:)
      @buy = buy
      @get = get

      super

      validates_buy_and_get!
    end

    def present
      "#{code} Buy #{buy} and get #{get} free discount for #{product.code} #{product.name}"
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

    def validates_buy_and_get!
      raise ArgumentError, '"buy" + "get" must be greater than zero' unless (buy + get).positive?
    end
  end
end
