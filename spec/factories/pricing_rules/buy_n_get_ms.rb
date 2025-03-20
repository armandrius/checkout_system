# frozen_string_literal: true

FactoryBot.define do
  factory(:buy_n_get_m_pricing_rule, class: 'PricingRules::BuyNGetM') do
    initialize_with { new(product:, buy:, get:) }

    product
    buy { rand(1..2) }
    get { buy + rand(1..2) }
  end
end
