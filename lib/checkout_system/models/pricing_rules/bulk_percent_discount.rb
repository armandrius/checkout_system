module PricingRules
  class BulkPercentDiscount < Base
    attr_accessor :product, :min_quantity, :discount_percentage

    def initialize(product: nil, min_quantity: nil, discount_percentage: nil)
      # TODO: validate
      @product = product
      @min_quantity = min_quantity
      @discount_percentage = discount_percentage
    end

    def final_price(line_item)
      return super if line_item.product != product || line_item.quantity < min_quantity

      (product.price * line_item.quantity) * (1 - discount_percentage / 100.0)
    end
  end
end
