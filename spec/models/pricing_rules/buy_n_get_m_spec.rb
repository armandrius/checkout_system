require 'spec_helper'

RSpec.describe PricingRules::BuyNGetM do
  let(:product) { Product.new(name: 'Test Product', price: 10.0, code: 'PR1') }
  let(:line_item) { LineItem.new(product:, quantity:) }
  let(:buy_n_get_m) { described_class.new(product:, buy:, get:) }

  describe '#final_price' do
    context 'when the product does not match' do
      let(:quantity) { 5 }
      let(:buy) { 2 }
      let(:get) { 3 }
      let(:price) { 15.0 }
      let(:other_product) { Product.new(name: 'Other Product', price:, code: 'PR2') }
      let(:line_item) { LineItem.new(product: other_product, quantity:) }

      it 'returns the original price' do
        expect(buy_n_get_m.final_price(line_item)).to eq(quantity * price)
      end
    end

    context 'when the quantity is less than the get value' do
      let(:quantity) { 2 }
      let(:buy) { 2 }
      let(:get) { 3 }
      let(:quantity_to_pay) { 2 }

      it 'returns the original price' do
        expect(buy_n_get_m.final_price(line_item)).to eq(quantity_to_pay * line_item.product.price)
      end
    end

    context 'when the quantity is equal to the get value' do
      let(:quantity) { 3 }
      let(:buy) { 2 }
      let(:get) { 3 }
      let(:quantity_to_pay) { 2 }

      it 'returns the discounted price' do
        expect(buy_n_get_m.final_price(line_item)).to eq(quantity_to_pay * line_item.product.price)
      end
    end

    context 'when the quantity is greater than the get value' do
      let(:quantity) { 6 }
      let(:buy) { 2 }
      let(:get) { 3 }
      let(:quantity_to_pay) { 3 }

      it 'returns the discounted price' do
        expect(buy_n_get_m.final_price(line_item)).to eq(quantity_to_pay * line_item.product.price)
      end
    end

    context 'when the quantity is not a multiple of the get value' do
      let(:quantity) { 7 }
      let(:buy) { 2 }
      let(:get) { 3 }
      let(:quantity_to_pay) { 4 }

      it 'returns the correct discounted price' do
        expect(buy_n_get_m.final_price(line_item)).to eq(quantity_to_pay * line_item.product.price)
      end
    end
  end
end