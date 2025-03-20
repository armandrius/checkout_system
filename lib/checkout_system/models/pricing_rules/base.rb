# frozen_string_literal: true

module PricingRules
  class Base
    attr_reader :product

    def initialize(product:, **_args)
      # TODO: assert product
      @product = product
    end

    def final_price(line_item)
      line_item.final_price
    end

    def product_matches?(line_item)
      line_item.product == product
    end
  end
end
