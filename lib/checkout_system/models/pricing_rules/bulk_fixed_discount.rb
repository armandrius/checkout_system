module PricingRules
  class BulkFixedDiscount < Base
    attr_accessor :product, :min_quantity, :price

    def initialize(product: nil, min_quantity: nil, price: nil)
      # TODO assert product, assert quantity > 2, price < product.price
      @product = product
      @min_quantity = min_quantity
      @price = price
    end

    def final_price(line_item)
      return super if line_item.product != product || line_item.quantity < min_quantity

      line_item.quantity * price
    end
  end
end
