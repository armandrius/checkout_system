FactoryBot.define do
  factory(:product) do
    name { Faker::Commerce.unique.product_name }
    code do
      # TODO: The product should generate the code automatically
      # since there is no database, there is nothing to check for uniqueness
      # but there is a need to check for uniqueness in the test
      Thread.current[:unique_code_names] ||= Set.new
      index = 1
      letters = name.gsub(/[aeiou\s]/i, '').upcase.first(2)
      index += 1 until Thread.current[:unique_code_names].add?(code = letters + index.to_s)
    end
    price { rand(100..100000).pounds }
    price_currency { 'GBP' }

    trait(:green_tea) do
      name { 'Green Tea' }
      code { 'GR1' }
      price { 3.11.pounds }
    end

    trait(:strawberry) do
      name { 'Strawberry' }
      code { 'SR1' }
      price { 5.00.pounds }
    end

    trait(:coffee) do
      name { 'Coffee' }
      code { 'CF1' }
      price { 11.23.pounds }
    end
  end
end
