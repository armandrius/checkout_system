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
    price_amount_cents { rand(100..100000) }
    price_currency { 'GBP' }

    trait(:gr1) do
      code { 'GR1' }
      price_amount_cents { 311 }
      price_currency { 'GBP' }
    end

    trait(:sr1) do
      code { 'SR1' }
      price_amount_cents { 500 }
      price_currency { 'GBP' }
    end

    trait(:cf1) do    
      code { 'CF1' }
      price_amount_cents { 1123 }
      price_currency { 'GBP' }
    end
  end
end
