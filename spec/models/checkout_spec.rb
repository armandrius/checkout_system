require 'spec_helper'

RSpec.describe Checkout do
  let(:green_tea) { FactoryBot.build(:product, :green_tea) }
  let(:strawberry) { FactoryBot.build(:product, :strawberry) }
  let(:coffee) { FactoryBot.build(:product, :coffee) }

  let(:buy) { 1 }
  let(:get) { 1 }
  let(:green_tea_pricing_rule) do
    FactoryBot.build(:buy_n_get_m_pricing_rule, product: green_tea, buy:, get:)
  end

  let(:reduced_stb_price) { 4.50.gbp }
  let(:strawberry_pricing_rule) do
    FactoryBot.build(:bulk_fixed_discount_pricing_rule, product: strawberry, min_quantity:, price: reduced_stb_price)
  end

  let(:discount_percentage) { 33.33333 }
  let(:coffee_pricing_rule) do
    FactoryBot.build(:bulk_percent_discount_pricing_rule, product: coffee, min_quantity:, discount_percentage:)
  end

  let(:pricing_rules) { [] }
  let(:checkout) { described_class.new(pricing_rules) }
  subject(:total) { checkout.total }

  describe '#scan' do
    context 'when argument is a product' do
      it 'adds a product to the basket' do
        expect { checkout.scan(green_tea) }.to change { checkout.line_items_list.products.count }.by(1)
      end

      it 'increments the quantity of the product in the basket' do
        expect { 2.times { checkout.scan(green_tea) } }.to change { checkout.line_items_list.quantity(green_tea) }.from(0).to(2)
      end
    end

    context 'when argument is not a product' do
      it 'raises an ArgumentError' do
        expect { checkout.scan('not a product') }.to raise_error(ArgumentError)
      end
    end
  end
  
  describe '#total' do
    context 'without any pricing_rules' do
      context 'when the basket is empty' do
        it 'costs nothing' do
          expect(total).to eq 0.gbp
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
          green_tea_quantity.times { checkout.scan(green_tea) }
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

    context 'with buy-one-get-one-free pricing_rules' do
      let(:buy) { 1 }
      let(:get) { 1 }
      let(:pricing_rules) { [green_tea_pricing_rule] }
      before { number_of_units.times { checkout.scan(green_tea) } }

      context 'when buying 1 unit' do
        let(:number_of_units) { 1 }
        let(:quantity_to_be_paid) { 1 }
        it 'costs the normal price' do
          expect(total).to eq(green_tea.price * quantity_to_be_paid)
        end
      end

      context 'when buying 2 units' do
        let(:number_of_units) { 2 }
        let(:quantity_to_be_paid) { 1 }

        it 'costs the same as one' do
          expect(total).to eq(green_tea.price * quantity_to_be_paid)
        end
      end

      context 'when buying an even number of units' do
        let(:number_of_units) { 4 }
        let(:quantity_to_be_paid) { 2 }
        
        it 'they cost half the expected price' do
          expect(total).to eq(green_tea.price * quantity_to_be_paid)
        end
      end

      context 'when buying an odd number of units' do
        let(:number_of_units) { 5 }
        let(:quantity_to_be_paid) { 3 }
        it 'they cost half the expected price plus one unit price' do
          expect(total).to eq(green_tea.price * quantity_to_be_paid)
        end
      end
    end

    context 'with lower prices for bulk purchases' do
      let(:min_quantity) { 3 }
      let(:pricing_rules) { [strawberry_pricing_rule] }

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
          expect(total).to eq(reduced_stb_price * quantity)
        end
      end

      context 'when buying more than the minimum quantity' do
        let(:quantity) { min_quantity + 1 }
        it 'costs the reduced price' do
          expect(total).to eq(reduced_stb_price * quantity)
        end
      end
    end

    context 'with reduced prices for bulk purchases' do
      let(:min_quantity) { 3 }
      let(:discount_percentage) { 33.33333 }
      let(:reduced_cff_price) do
        coffee.price * quantity * (1 - discount_percentage / 100)
      end
      let(:pricing_rules) { [coffee_pricing_rule] }

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
          expect(total).to eq(reduced_cff_price)
        end
      end

      context 'when buying more than the minimum quantity' do
        let(:quantity) { min_quantity + 1 }
        it 'costs the reduced price' do
          expect(total).to eq(reduced_cff_price)
        end
      end
    end

    context 'with multiple pricing_rules' do
      let(:min_quantity) { 3 }
      let(:pricing_rules) { [green_tea_pricing_rule, strawberry_pricing_rule, coffee_pricing_rule] }

      context 'Basket: GR1, SR1, GR1, GR1, CF1' do
        before do
          3.times { checkout.scan(green_tea) }
          1.times { checkout.scan(strawberry) }
          1.times { checkout.scan(coffee) }
        end
        it 'costs the correct total' do
          expect(total).to eq 22.45.gbp
        end
      end
      
      context 'Basket: GR1, GR1' do
        before do
          2.times { checkout.scan(green_tea) }
        end
        it 'costs the correct total' do
          expect(total).to eq 3.11.gbp
        end
      end
      
      context 'Basket: SR1, SR1, GR1, SR1' do
        before do
          3.times { checkout.scan(strawberry) }
          1.times { checkout.scan(green_tea) }
        end
        it 'costs the correct total' do
          expect(total).to eq 16.61.gbp
        end
      end
      
      context 'Basket: GR1, CF1, SR1, CF1, CF1' do
        before do
          1.times { checkout.scan(green_tea) }
          3.times { checkout.scan(coffee) }
          1.times { checkout.scan(strawberry) }
        end
        it 'costs the correct total' do
          expect(total).to eq 30.57.gbp
        end
      end
    end
  end
end
