RSpec.describe Checkout do
  let(:green_tea) { FactoryBot.build(:product, :green_tea) }
  let(:strawberry) { FactoryBot.build(:product, :strawberry) }
  let(:coffee) { FactoryBot.build(:product, :coffee) }

  let(:green_tea_offer) do
    FactoryBot.build(:buy_n_get_m_offer, product: green_tea, buy: 1, get: 1)
  end
  let(:strawberry_offer) do
    FactoryBot.build(:bulk_discount_absolute_offer, product: strawberry, min_quantity:, price:)
  end
  let(:coffee_offer) do
    FactoryBot.build(:bulk_discount_relative_offer, product: coffee, min_quantity:, discount_percentage:)
  end

  let(:pricing_rules) { [] }
  let(:checkout) { described_class.new(pricing_rules) }
  subject(:total) { checkout.total }

  describe '#scan' do
    context 'when argument is a product' do
      before { checkout.scan(green_tea) }
      it 'adds a product to the basket' do
        expect(checkout.products).to include(green_tea)
      end
    end

    context 'when argument is not a product' do
      it 'raises an ArgumentError' do
        expect { checkout.scan('not a product') }.to raise_error(ArgumentError)
      end
    end
  end
  
  describe '#total' do
    context 'without any offers' do
      context 'when the basket is empty' do
        it 'costs nothing' do
          expect(total).to eq 0.pounds
        end
      end

      context 'when buying one unit' do
        before { checkout.scan(green_tea) }
        it 'costs the price of one unit of product' do
          expect(total).to eq green_tea.price
        end
      end

      context 'when buying multiple units' do
        let(:number_of_units) { 3 }
        before { number_of_units.times { checkout.scan(green_tea) } }
        it 'costs the price of the product times the number of units' do
          expect(total).to eq green_tea.price * number_of_units
        end
      end

      context 'when combining multiple products' do
        let(:green_tea_quantity) { 1 }
        let(:strawberry_quantity) { 2 }
        let(:coffeee_quantity) { 3 }

        before do
          green_tea_quantity.time { checkout.scan(green_tea) }
          strawberry_quantity.times { checkout.scan(strawberry) }
          coffeee_quantity.times { checkout.scan(coffee) }
        end

        it 'calculates the total price correctly' do
          expect(total).to eq(
            green_tea.price * green_tea_quantity +
            strawberry.price * strawberry_quantity +
            coffee.price * coffeee_quantity
          )
        end
      end
    end

    context 'with buy-one-get-one-free offers' do
      let(:pricing_rules) { [green_tea_offer] }

      context 'when buying 1 unit' do
        before { checkout.scan(green_tea) }
        it 'costs the normal price' do
          expect(total).to eq green_tea.price
        end
      end

      context 'when buying 2 units' do
        before { 2.times { checkout.scan(green_tea) } }
        it 'costs the same as one' do
          expect(total).to eq green_tea.price
        end
      end

      context 'when buying an even number of units' do
        let(:number_of_units) { 4 }
        before { number_of_units.times { checkout.scan(green_tea) } }

        it 'they cost half the expected price' do
          expect(total).to eq(green_tea.price * (number_of_units / 2))
        end
      end

      context 'when buying an odd number of units' do
        let(:number_of_units) { 5 }
        it 'they cost half the expected price plus one unit price' do
          expect(total).to eq(green_tea.price * (number_of_units / 2 + 1))
        end
      end
    end

    context 'with lower prices for bulk purchases' do
      let(:min_quantity) { 3 }
      let(:price) { 4.50.pounds }
      let(:pricing_rules) { [strawberry_offer] }

      before { quantity.times { checkout.scan(strawberry) } }

      context 'when buying less than the minimum quantity' do
        let(:quantity) { min_quantity - 1 }
        it 'costs the normal price' do
          expect(total).to eq strawberry.price * quantity
        end
      end

      context 'when buying the minimum quantity' do
        let(:quantity) { min_quantity }
        it 'costs the reduced price' do
          expect(total).to eq(price * quantity)
        end
      end

      context 'when buying more than the minimum quantity' do
        let(:quantity) { min_quantity + 1 }
        it 'costs the reduced price' do
          expect(total).to eq(price * quantity)
        end
      end
    end

    context 'with reduced prices for bulk purchases' do
      let(:min_quantity) { 3 }
      let(:discount_percentage) { 33.33 }
      let(:reduced_price) do
        # Money.new((coffee.price.cents * (1 - discount_percentage / 100)).round(2), coffee.price.currency)
        coffee.price.with_discount(percentage: discount_percentage)
      end
      let(:pricing_rules) { [coffee_offer] }

      before { quantity.times { checkout.scan(coffee) } }

      context 'when buying less than the minimum quantity' do
        let(:quantity) { min_quantity - 1 }
        it 'costs the normal price' do
          expect(total).to eq(coffee.price * quantity)
        end
      end

      context 'when buying the minimum quantity' do
        let(:quantity) { min_quantity }
        it 'costs the reduced price' do
          expect(total).to eq(reduced_price * quantity)
        end
      end

      context 'when buying more than the minimum quantity' do
        let(:quantity) { min_quantity + 1 }
        it 'costs the reduced price' do
          expect(total).to eq(reduced_price * quantity)
        end
      end
    end

    context 'with multiple offers' do
      let(:pricing_rules) { [green_tea_offer, strawberry_offer, coffee_offer] }

      context 'Basket: GR1, SR1, GR1, GR1, CF1' do
        before do
          3.times { checkout.scan(green_tea) }
          1.time { checkout.scan(strawberry) }
          1.time { checkout.scan(coffee) }
        end
        expect(total).to eq 22.45.pounds
      end
      
      context 'Basket: GR1, GR1' do
        before do
          2.times { checkout.scan(green_tea) }
        end
        expect(total).to eq 3.11.pounds
      end
      
      context 'Basket: SR1, SR1, GR1, SR1' do
        before do
          3.times { checkout.scan(strawberry) }
          1.time { checkout.scan(green_tea) }
        end
        expect(total).to eq 16.61.pounds
      end
      
      context 'Basket: GR1, CF1, SR1, CF1, CF1' do
        before do
          1.time { checkout.scan(green_tea) }
          3.times { checkout.scan(coffee) }
          1.time { checkout.scan(strawberry) }
        end
        expect(total).to eq 30.57.pounds
      end
    end
  end
end
