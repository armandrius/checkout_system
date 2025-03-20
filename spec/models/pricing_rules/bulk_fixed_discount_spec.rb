# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PricingRules::BulkFixedDiscount do
  let(:product) { build(:product, name: 'Product') }
  let(:bulk_fixed_discount) { described_class.new(product:, min_quantity: 3, price: 80) }
  let(:original_total) { quantity * product.price }
  let(:line_item) { instance_double(LineItem, product:, quantity:, final_price: original_total) }

  describe '#final_price' do
    subject { bulk_fixed_discount.final_price(line_item) }

    shared_examples_for 'returns the original price' do
      it 'returns the original price' do
        expect(subject).to eq(original_total)
      end
    end

    shared_examples_for 'returns the discounted price' do
      it 'returns the discounted price' do
        expect(subject).to eq(quantity * bulk_fixed_discount.price)
      end
    end

    context 'when line item product is different' do
      let(:quantity) { bulk_fixed_discount.min_quantity }

      before { allow(line_item).to receive(:product).and_return(build(:product, name: 'Different Product')) }

      it_behaves_like 'returns the original price'
    end

    context 'when line item quantity is less than minimum quantity' do
      let(:quantity) { bulk_fixed_discount.min_quantity - 1 }

      it_behaves_like 'returns the original price'
    end

    context 'when line item quantity is equal to minimum quantity' do
      let(:quantity) { bulk_fixed_discount.min_quantity }

      it_behaves_like 'returns the discounted price'
    end

    context 'when line item quantity is greater than minimum quantity' do
      let(:quantity) { bulk_fixed_discount.min_quantity + 1 }

      it_behaves_like 'returns the discounted price'
    end
  end
end
