module PricingRules
  class BuyNGetM < Base
    attr_accessor :product, :buy, :get

    def initialize(product: nil, buy: nil, get: nil)
      # TODO: validate inputs, get > buy
      @product = product
      @buy = buy
      @get = get
    end

    def final_price(line_item)
      quantity = line_item.quantity
      original_price = line_item.product.price

      return super if line_item.product != product || quantity < get

      complete_groups, incomplete_group = quantity.divmod(buy + get)
      quantity_to_be_paid = complete_groups * buy + [incomplete_group, buy].min

      original_price * quantity_to_be_paid
    end
  end
end
