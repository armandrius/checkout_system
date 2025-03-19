require 'spec_helper'

RSpec.describe PricingRules::BulkFixedDiscount do
  let(:product) { instance_double('Product', price: 100) }
  let(:min_quantity) { 3 }
  let(:price) { 80 }
  let(:bulk_fixed_discount) { described_class.new(product:, min_quantity:, price:) }
  let(:original_total) { quantity * product.price }
  let(:reduced_total) { quantity * price }
  let(:line_item) { instance_double('LineItem', product:, quantity:, final_price: original_total) }

  describe '#final_price' do
    subject { bulk_fixed_discount.final_price(line_item) }

    shared_examples_for 'returns the original price' do
      it 'returns the original price' do
        expect(subject).to eq(original_total)
      end
    end

    shared_examples_for 'returns the discounted price' do
      it 'returns the discounted price' do
        expect(subject).to eq(reduced_total)
      end
    end

    context 'when line item product is different' do
      let(:other_product) { double('Product') }
      let(:quantity) { min_quantity }
      let(:line_item) { double('LineItem', product: other_product, quantity:, final_price: original_total) }

      it_behaves_like 'returns the original price'
    end


    context 'when line item quantity is less than minimum quantity' do
      let(:quantity) { 2 }

      it_behaves_like 'returns the original price'
    end

    context 'when line item quantity is equal to minimum quantity' do
      let(:quantity) { min_quantity }

      it_behaves_like 'returns the discounted price'
    end

    context 'when line item quantity is greater than minimum quantity' do
      let(:quantity) { 5 }

      it_behaves_like 'returns the discounted price'
    end
  end
end
