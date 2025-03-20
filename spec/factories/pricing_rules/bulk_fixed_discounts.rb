# frozen_string_literal: true

FactoryBot.define do
  factory(:bulk_fixed_discount_pricing_rule, class: 'PricingRules::BulkFixedDiscount') do
    initialize_with { new(code:, product:, min_quantity:, price:) }

    sequence(:code) { |n| "bulk_fixed_discount_#{n}" }
    product
    min_quantity { rand(2..20) }
    price { product.price * 0.8 }
  end
end
