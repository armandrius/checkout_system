RSpec.describe Checkout do
  let(:green_tea) { FactoryBot.build(:product, :gr1) }
  let(:pricing_rules) { [] }
  let(:checkout) { described_class.new(pricing_rules) }
  subject(:total) { checkout.total }

  context 'with buy-one-get-one-free offers' do
    let(:pricing_rules) { [FactoryBot.build(:offer, :buy_n_get_m, product: green_tea, n: 1, m: 1)] }

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
