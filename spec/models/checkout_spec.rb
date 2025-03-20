# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Checkout do
  subject(:total) { checkout.total }

  shared_context 'with buy-one-get-one-free pricing rule' do
    let(:green_tea) { build(:product, :green_tea) }
    let(:buy) { 1 }
    let(:get) { 1 }
    let(:green_tea_pricing_rule) do
      build(:buy_n_get_m_pricing_rule, product: green_tea, buy:, get:)
    end
  end

  shared_context 'with bulk fixed amount disocunt' do
    let(:strawberry) { build(:product, :strawberry) }
    let(:min_str_quantity) { 3 }
    let(:reduced_stb_price) { 4.50.gbp }
    let(:strawberry_pricing_rule) do
      build(
        :bulk_fixed_discount_pricing_rule,
        product: strawberry,
        min_quantity: min_str_quantity,
        price: reduced_stb_price
      )
    end
  end

  shared_context 'with bulk percentage discount' do
    let(:coffee) { build(:product, :coffee) }
    let(:min_cff_quantity) { 3 }
    let(:discount_percentage) { Rational(100, 3) }
    let(:reduced_cff_price) do
      coffee.price * quantity * (1 - (discount_percentage / 100))
    end
    let(:coffee_pricing_rule) do
      build(:bulk_percent_discount_pricing_rule, product: coffee, min_quantity: min_cff_quantity, discount_percentage:)
    end
  end

  describe '#scan' do
    let(:checkout) { described_class.new }

    context 'when argument is a product' do
      let(:product) { build(:product) }

      it 'adds a product to the basket' do
        expect { checkout.scan(product) }.to change { checkout.line_items_list.products.count }.by(1)
      end

      it 'increments the quantity of the product in the basket' do
        expect { 2.times { checkout.scan(product) } }.to change {
          checkout.line_items_list.quantity(product)
        }.from(0).to(2)
      end
    end

    context 'when argument is not a product' do
      it 'raises an ArgumentError' do
        expect { checkout.scan('not a product') }.to raise_error(ArgumentError)
      end
    end

    context 'when attempting to scan a product with a different currency' do
      let(:checkout) { described_class.new }

      before { checkout.scan(build(:product, price: 1.eur)) }

      it 'raises an ArgumentError' do
        expect { checkout.scan(build(:product, price: 1.usd)) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#empty' do
    let(:checkout) { described_class.new(build(:buy_n_get_m_pricing_rule)) }

    before do
      3.times { checkout.scan(build(:product)) }
    end

    it 'empties the basket' do
      expect { checkout.empty }.to(change { checkout.line_items_list.total_items }.from(3).to(0))
    end

    it "doesn't clear pricing rules" do
      expect { checkout.empty }.not_to(change { checkout.pricing_rules_list.each.count })
    end
  end

  describe '#total' do
    context 'without any pricing_rules' do
      let(:checkout) { described_class.new }

      context 'when the basket is empty' do
        it 'costs nothing' do
          expect(total).to eq 0.gbp
        end
      end

      context 'when buying one unit' do
        let(:product) { build(:product) }

        before { checkout.scan(product) }

        it 'costs the price of one unit of product' do
          expect(total).to eq product.price
        end
      end

      context 'when buying multiple units' do
        let(:product) { build(:product) }
        let(:number_of_units) { 3 }

        before { number_of_units.times { checkout.scan(product) } }

        it 'costs the price of the product times the number of units' do
          expect(total).to eq product.price * number_of_units
        end
      end

      context 'when combining multiple products' do
        let(:potato) { build(:product, name: 'Potato') }
        let(:spaghetti) { build(:product, name: 'Spaghetti') }
        let(:apple) { build(:product, name: 'Apple') }

        before do
          checkout.scan(potato)
          2.times { checkout.scan(spaghetti) }
          3.times { checkout.scan(apple) }
        end

        it 'calculates the total price correctly' do
          expect(total).to eq(potato.price + (spaghetti.price * 2) + (apple.price * 3))
        end
      end
    end

    context 'with buy-one-get-one-free pricing_rules' do
      let(:checkout) { described_class.new([green_tea_pricing_rule]) }

      include_context 'with buy-one-get-one-free pricing rule'

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

    context 'with fixed amount discount for bulk purchases' do
      let(:checkout) { described_class.new([strawberry_pricing_rule]) }

      include_context 'with bulk fixed amount disocunt'

      before { quantity.times { checkout.scan(strawberry) } }

      context 'when buying less than the minimum quantity' do
        let(:quantity) { min_str_quantity - 1 }

        it 'costs the normal price' do
          expect(total).to eq strawberry.price * quantity
        end
      end

      context 'when buying the minimum quantity' do
        let(:quantity) { min_str_quantity }

        it 'costs the reduced price' do
          expect(total).to eq(reduced_stb_price * quantity)
        end
      end

      context 'when buying more than the minimum quantity' do
        let(:quantity) { min_str_quantity + 1 }

        it 'costs the reduced price' do
          expect(total).to eq(reduced_stb_price * quantity)
        end
      end
    end

    context 'with percentage discount for bulk purchases' do
      let(:checkout) { described_class.new([coffee_pricing_rule]) }

      include_context 'with bulk percentage discount'

      before { quantity.times { checkout.scan(coffee) } }

      context 'when buying less than the minimum quantity' do
        let(:quantity) { min_cff_quantity - 1 }

        it 'costs the normal price' do
          expect(total).to eq(coffee.price * quantity)
        end
      end

      context 'when buying the minimum quantity' do
        let(:quantity) { min_cff_quantity }

        it 'costs the reduced price' do
          expect(total).to eq(reduced_cff_price)
        end
      end

      context 'when buying more than the minimum quantity' do
        let(:quantity) { min_cff_quantity + 1 }

        it 'costs the reduced price' do
          expect(total).to eq(reduced_cff_price)
        end
      end
    end

    context 'with multiple pricing_rules' do
      let(:checkout) do
        described_class.new([
                              green_tea_pricing_rule,
                              strawberry_pricing_rule,
                              coffee_pricing_rule
                            ])
      end

      include_context 'with buy-one-get-one-free pricing rule'
      include_context 'with bulk fixed amount disocunt'
      include_context 'with bulk percentage discount'

      describe 'Basket: GR1, SR1, GR1, GR1, CF1' do
        before do
          3.times { checkout.scan(green_tea) }
          checkout.scan(strawberry)
          checkout.scan(coffee)
        end

        it 'costs the correct total' do
          expect(total).to eq 22.45.gbp
        end
      end

      describe 'Basket: GR1, GR1' do
        before do
          2.times { checkout.scan(green_tea) }
        end

        it 'costs the correct total' do
          expect(total).to eq 3.11.gbp
        end
      end

      describe 'Basket: SR1, SR1, GR1, SR1' do
        before do
          3.times { checkout.scan(strawberry) }
          checkout.scan(green_tea)
        end

        it 'costs the correct total' do
          expect(total).to eq 16.61.gbp
        end
      end

      describe 'Basket: GR1, CF1, SR1, CF1, CF1' do
        before do
          checkout.scan(green_tea)
          3.times { checkout.scan(coffee) }
          checkout.scan(strawberry)
        end

        it 'costs the correct total' do
          expect(total).to eq 30.57.gbp
        end
      end
    end
  end
end
