module PricingRules
  class BulkPercentDiscount < Base
    attr_accessor :product, :min_quantity, :discount_percentage
  end
end
