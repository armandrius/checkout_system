FactoryBot.define do
  factory(:buy_n_get_m_pricing_rule, class: 'PricingRules::BuyNGetM') do
    product { build(:product) }
    buy { rand(1..2) }
    get { buy + rand(1..2) }
  end
end
