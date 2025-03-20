# frozen_string_literal: true

FactoryBot.define do
  factory(:buy_n_get_m_pricing_rule, class: 'PricingRules::BuyNGetM') do
    initialize_with { new(code:, product:, buy:, get:) }

    sequence(:code) { |n| "buy_n_get_m_#{n}" }
    product
    buy { rand(1..2) }
    get { buy + rand(1..2) }
  end
end
