require 'spec_helper'

RSpec.describe PricingRules::BulkPercentDiscount do
  let(:product) { instance_double('Product', price: 100) }
  let(:original_total) { product.price * quantity }
  let(:line_item) { instance_double('LineItem', product:, quantity:, final_price: original_total) }
  let(:min_quantity) { 5 }
  let(:pricing_rule) { described_class.new(product:, min_quantity:, discount_percentage: 10) }
  let(:reduced_total) { original_total * 0.9 }

  describe '#final_price' do

    shared_examples_for 'applies the discount' do
      it 'applies the discount' do
        expect(pricing_rule.final_price(line_item)).to eq(reduced_total)
      end
    end

    context 'when line item quantity is less than minimum quantity' do
      let(:quantity) { 3 }

      it 'returns the original price' do
        expect(pricing_rule.final_price(line_item)).to eq(original_total)
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
      let(:different_product) { instance_double('Product', price: 200) }
      let(:line_item) { instance_double('LineItem', product: different_product, quantity:, final_price: different_product.price * quantity) }

      it 'returns the original price' do
        expect(pricing_rule.final_price(line_item)).to eq(different_product.price * quantity)
      end
    end
  end
end