require 'spec_helper'

RSpec.describe Product do
  let(:product_name) { 'Sky eraser' }
  let(:product) { FactoryBot.build(:product, name: product_name, code: 'P001', price: 100.0) }
  let(:product1) { FactoryBot.build(:product, code: 'P001') }
  let(:product2) { FactoryBot.build(:product, code: 'P002') }

  describe '#initialize' do
    it 'assigns code' do
      expect(product.code).to eq('P001')
    end

    it 'assigns name' do
      expect(product.name).to eq(product_name)
    end

    it 'assigns price' do
      expect(product.price).to eq(100.0)
    end
  end

  describe '#==' do
    it 'returns true for products with the same code' do
      expect(product1).to eq(product1)
    end

    it 'returns false for products with different codes' do
      expect(product1).not_to eq(product2)
    end

    it 'returns false when comparing with a non-product object' do
      non_product = instance_double('NonProduct', code: 'P001')
      expect(product1).not_to eq(non_product)
    end
  end
end
