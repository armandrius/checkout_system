module PricingRules
  class BulkFixedDiscount < Base
    attr_accessor :product, :min_quantity, :price
  end
end
