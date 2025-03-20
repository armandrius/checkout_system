# frozen_string_literal: true

FactoryBot.define do
  factory(:bulk_percent_discount_pricing_rule, class: 'PricingRules::BulkPercentDiscount') do
    initialize_with { new(code:, product:, min_quantity:, discount_percentage:) }

    sequence(:code) { |n| "bulk_percent_discount_#{n}" }
    product
    min_quantity { rand(2..10) }
    discount_percentage { (rand * 50).round(2) }
  end
end
