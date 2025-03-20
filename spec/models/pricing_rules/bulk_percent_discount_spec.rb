# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PricingRules::BulkPercentDiscount do
  let(:line_item) do
    instance_double(
      LineItem,
      product: build(:product, price: 100),
      quantity:,
      final_price: 100 * quantity
    )
  end
  let(:min_quantity) { 5 }
  let(:pricing_rule) { described_class.new(product: line_item.product, min_quantity:, discount_percentage: 10) }

  describe '#final_price' do
    shared_examples_for 'applies the discount' do
      it 'applies the discount' do
        expect(pricing_rule.final_price(line_item)).to eq(line_item.final_price * 0.9)
      end
    end

    context 'when line item quantity is less than minimum quantity' do
      let(:quantity) { 3 }

      it 'returns the original price' do
        expect(pricing_rule.final_price(line_item)).to eq(line_item.final_price)
      end
    end

    context 'when line item quantity is equal to the minimum quantity' do
      let(:quantity) { min_quantity }

      it_behaves_like 'applies the discount'
    end

    context 'when line item quantity is greater than the minimum quantity' do
      let(:quantity) { min_quantity + 1 }

      it_behaves_like 'applies the discount'
    end

    context 'when line item product is different from discount rule product' do
      let(:quantity) { 5 }
      let(:different_product) { build(:product, price: 200) }

      before do
        allow(pricing_rule).to receive(:product).and_return(build(:product))
        allow(line_item).to(
          receive_messages(
            product: different_product,
            final_price: different_product.price * quantity
          )
        )
      end

      it 'returns the original price' do
        expect(pricing_rule.final_price(line_item)).to eq(different_product.price * quantity)
      end
    end
  end
end
