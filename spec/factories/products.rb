FactoryBot.define do
  factory(:product) do
    sequence(:name) { |n| "Product #{n}" }
    price { rand(100..100_000).gbp }

    trait(:green_tea) do
      name { 'Green Tea' }
      code { 'GR1' }
      price { 3.11.gbp }
    end

    trait(:strawberry) do
      name { 'Strawberry' }
      code { 'SR1' }
      price { 5.00.gbp }
    end

    trait(:coffee) do
      name { 'Coffee' }
      code { 'CF1' }
      price { 11.23.gbp }
    end
  end
end
