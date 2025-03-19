FactoryBot.define do
  factory(:bulk_percent_discount_pricing_rule, class: 'PricingRules::BulkPercentDiscount') do
    product { build(:product) }
    min_quantity { rand(2..10) }
    discount_percentage { (rand * 50).round(2) }
  end
end
