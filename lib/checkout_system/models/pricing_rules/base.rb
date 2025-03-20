# frozen_string_literal: true

module PricingRules
  class Base
    include Concerns::Assertable

    attr_reader :product

    def initialize(product:, **_args)
      assert_class!(:product, product, Product)

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
