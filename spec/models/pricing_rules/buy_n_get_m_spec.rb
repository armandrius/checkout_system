# frozen_string_literal: true

require 'debug'
require 'spec_helper'

RSpec.describe PricingRules::BuyNGetM do
  let(:buy_n_get_m) { described_class.new(code: 'code_0', product: build(:product), buy:, get:) }

  describe '#initialize' do
    let(:product) { build(:product) }
    let(:code) { 'code_1' }

    it 'validates that N must not be negative' do
      expect { described_class.new(code:, product:, buy: -1, get: 1) }.to raise_error(ArgumentError)
    end

    it 'validates that M must not be negative' do
      expect { described_class.new(code:, product:, buy: 1, get: -1) }.to raise_error(ArgumentError)
    end

    it 'validates that N must be an integer' do
      expect { described_class.new(code:, product:, buy: 1.1, get: 1) }.to raise_error(ArgumentError)
    end

    it 'validates that M must be an integer' do
      expect { described_class.new(code:, product:, buy: 1, get: 1.1) }.to raise_error(ArgumentError)
    end

    it 'validates that N + M are greater than zero' do
      expect { described_class.new(code:, product:, buy: 0, get: 0) }.to raise_error(ArgumentError)
    end
  end

  describe '#quantity_to_pay' do
    context 'when the product matches' do
      subject(:quantity_to_pay) { buy_n_get_m.quantity_to_pay(quantity) }

      shared_examples_for 'buy N get M' do
        context 'when the quantity is smaller than the N value' do
          let(:quantity) { buy - 1 }

          it 'must pay all items' do
            expect(quantity_to_pay).to eq(quantity)
          end
        end

        context 'when the quantity is equal to the N value' do
          let(:quantity) { buy }

          it 'must pay N items (all items)' do
            expect(quantity_to_pay).to eq(quantity)
          end
        end

        context 'when the quantity is greater than N but smaller than N + M' do
          let(:quantity) { buy + get - 1 }

          it 'must only pay N items' do
            expect(quantity_to_pay).to eq(buy)
          end
        end

        context 'when the quantity is equal to N + M' do
          let(:quantity) { buy + get }

          it 'must only pay N items' do
            expect(quantity_to_pay).to eq(buy)
          end
        end

        context 'when the quantity is equal to N + M + 1' do
          let(:quantity) { buy + get + 1 }

          it 'must pay N + 1 items' do
            expect(quantity_to_pay).to eq(buy + 1)
          end
        end

        context 'when the quantity a multiple of N + M' do
          let(:multiple) { 5 }
          let(:quantity) { (buy + get) * multiple }

          it 'must pay N items of each group' do
            expect(quantity_to_pay).to eq(buy * multiple)
          end
        end

        context 'when the quantity is between a multiple of N + M and the next multiple' do
          let(:multiple) { 5 }
          let(:quantity) { ((buy + get) * multiple) + 1 }

          it 'must pay N items of each group plus one' do
            expect(quantity_to_pay).to eq((buy * multiple) + 1)
          end
        end
      end

      context 'when you buy 1 and get another for free' do
        it_behaves_like 'buy N get M' do
          let(:buy) { 1 }
          let(:get) { 1 }
        end
      end

      context 'when you buy 2 and get another for free' do
        it_behaves_like 'buy N get M' do
          let(:buy) { 2 }
          let(:get) { 1 }
        end
      end

      context 'when you buy 5 and get 4 more for free' do
        it_behaves_like 'buy N get M' do
          let(:buy) { 5 }
          let(:get) { 4 }
        end
      end

      context 'when you buy 10 and get 29 more for free' do
        it_behaves_like 'buy N get M' do
          let(:buy) { 10 }
          let(:get) { 29 }
        end
      end

      context "when you 'buy 0' and get some for free" do
        let(:quantity) { 9 }
        let(:buy) { 0 }
        let(:get) { 1 }

        it 'means they are all free' do
          expect(quantity_to_pay).to be_zero
        end
      end
    end
  end

  describe '#final_price' do
    context 'when the product does not match' do
      let(:buy) { 1 }
      let(:get) { 1 }
      let(:quantity) { 10 }
      let(:line_item) { LineItem.new(product: build(:product), quantity:) }

      it 'must pay all items' do
        expect(buy_n_get_m.final_price(line_item)).to eq(line_item.product.price * quantity)
      end

      it 'the pricing rule does not calculate any discount' do
        expect(buy_n_get_m).not_to receive(:quantity_to_pay)
      end
    end
  end
end
