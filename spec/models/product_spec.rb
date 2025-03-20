# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Product do
  let(:banana) { build(:product, name: 'banana', code: 'P001') }
  let(:apple) { build(:product, name: 'banana', code: 'P002') }

  describe '#==' do
    it 'returns true for products with the same code' do
      expect(banana).to eq(build(:product, code: banana.code))
    end

    it 'returns false for products with different codes' do
      expect(banana).not_to eq(apple)
    end

    it 'returns false when comparing with a non-product object' do
      expect(banana).not_to eq(instance_double(described_class, code: 'P001'))
    end
  end
end
