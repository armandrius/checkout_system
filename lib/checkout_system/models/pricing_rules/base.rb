# frozen_string_literal: true

module PricingRules
  class Base
    include Concerns::Validatable
    include Concerns::CodeIdentifiable

    attr_reader :product

    validates :product, Product

    def initialize(code:, product:, **_args)
      @product = product
      @code = code

      validate!
    end

    def present
      "#{code}-#{self.class.name} for #{product.code} #{product.name}"
    end

    def final_price(line_item)
      line_item.final_price
    end

    def product_matches?(line_item)
      line_item.product == product
    end
  end
end
