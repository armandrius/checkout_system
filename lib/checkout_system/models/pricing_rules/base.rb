module PricingRules
  class Base
    attr_accessor :product
    
    def final_price(line_item)
      line_item.final_price
    end
  end
end