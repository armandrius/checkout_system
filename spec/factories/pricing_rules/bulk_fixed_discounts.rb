FactoryBot.define do
  factory(:bulk_fixed_discount_pricing_rule, class: 'PricingRules::BulkFixedDiscount') do
    product { build(:product) }
    min_quantity { rand(2..20) }
    price { product.price * 0.8 }
  end
end
