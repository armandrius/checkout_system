# frozen_string_literal: true

module PricingRules
  class Base
    include Concerns::Assertable

    attr_reader :code, :product

    def initialize(code:, product:, **_args)
      @product = product
      @code = code

      validate_code!
      validate_product!
    end

    def final_price(line_item)
      line_item.final_price
    end

    def product_matches?(line_item)
      line_item.product == product
    end

    private

    def validate_code!
      assert_class!(:code, code, String)

      raise(ArgumentError, 'code cannot be empty') unless code.length.positive?
    end

    def validate_product!
      assert_class!(:product, product, Product)
    end
  end
end
