# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LineItem do
  let(:product) { build(:product, price: 100.eur) }
  let(:line_item) { described_class.new(product:, quantity: 2) }
  let(:pricing_rule) { PricingRules::Base.new(code: 'code', product:) }

  shared_examples 'cannot be modified' do
    it 'raises an error' do
      expect { action }.to raise_error(LineItem::ImmutableQuantityError)
    end
  end

  shared_context 'with a pricing rule applied' do
    before { line_item.apply_pricing_rule(pricing_rule) }
  end

  describe '#increment' do
    context 'when no pricing rule is applied' do
      before { line_item.increment }

      it 'increases the quantity by 1' do
        expect(line_item.quantity).to eq(3)
      end

      it 'updates the final price' do
        expect(line_item.final_price).to eq(300.eur)
      end
    end

    context 'when a pricing rule is applied' do
      include_context 'with a pricing rule applied'

      it_behaves_like 'cannot be modified' do
        subject(:action) { line_item.increment }
      end
    end
  end

  describe '#decrement' do
    context 'when no pricing rule is applied' do
      before { line_item.decrement }

      it 'decreases the quantity by 1' do
        expect(line_item.quantity).to eq(1)
      end

      it 'updates the final price' do
        expect(line_item.final_price).to eq(100.eur)
      end

      it 'does not decrease the quantity below 0' do
        2.times { line_item.decrement }
        expect(line_item.quantity).to eq(0)
      end
    end

    context 'when a pricing rule is applied' do
      include_context 'with a pricing rule applied'

      it_behaves_like 'cannot be modified' do
        subject(:action) { line_item.decrement }
      end
    end
  end

  describe '#apply_pricing_rule' do
    let(:modified_price) { 150.eur }

    before { allow(pricing_rule).to receive(:final_price).and_return(modified_price) }

    it 'applies the pricing rule' do
      line_item.apply_pricing_rule(pricing_rule)
      expect(line_item.final_price).to eq(modified_price)
    end

    it 'adds the pricing rule to the applied rules' do
      line_item.apply_pricing_rule(pricing_rule)
      expect(line_item.pricing_rules_applied).to include(pricing_rule)
    end

    it 'raises an error if the argument is not a pricing rule' do
      expect { line_item.apply_pricing_rule('not_a_pricing_rule') }.to raise_error(ArgumentError)
    end
  end
end
