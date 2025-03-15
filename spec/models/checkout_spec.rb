RSpec.describe Checkout do
  let(:green_tea) { FactoryBot.build(:product, :green_tea) }
  let(:strawberry) { FactoryBot.build(:product, :strawberry) }
  let(:coffee) { FactoryBot.build(:product, :coffee) }

  let(:pricing_rules) { [] }
  let(:checkout) { described_class.new(pricing_rules) }
  subject(:total) { checkout.total }

  context 'with buy-one-get-one-free offers' do
    let(:pricing_rules) { [FactoryBot.build(:buy_n_get_m_offer, product: green_tea, buy: 1, get: 1)] }

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

  context 'with price discounts for bulk purchases' do
    let(:min_quantity) { 3 }
    let(:price) { 4.50.pounds }
    let(:pricing_rules) do
      [FactoryBot.build(:bulk_discount_offer, product: strawberry, min_quantity:, price:)]
    end

    before { quantity.times { checkout.scan(strawberry) } }

    context 'when buying less than the minimum quantity' do
      let(:quantity) { min_quantity - 1 }
      it 'costs the normal price' do
        expect(total).to eq strawberry.price * quantity
      end
    end

    context 'when buying the minimum quantity' do
      let(:quantity) { min_quantity }
      it 'costs the discounted price' do
        expect(total).to eq(price * quantity)
      end
    end

    context 'when buying more than the minimum quantity' do
      let(:quantity) { min_quantity + 1 }
      it 'costs the discounted price' do
        expect(total).to eq(price * quantity)
      end
    end
  end

  context 'Basket: GR1, SR1, GR1, GR1, CF1' do
    expect(total).to eq 22.45.pounds
  end
  
  context 'Basket: GR1, GR1' do
    expect(total).to eq 3.11.pounds
  end
  
  context 'Basket: SR1, SR1, GR1, SR1' do
    expect(total).to eq 16.61.pounds
  end
  
  context 'Basket: GR1, CF1, SR1, CF1, CF1' do
    expect(total).to eq 30.57.pounds
  end
end
