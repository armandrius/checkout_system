# frozen_string_literal: true

class DiscountAddedView
  def initialize(pricing_rule)
    @pricing_rule = pricing_rule
  end

  def render
    puts "#{@pricing_rule.present} added!"
  end
end
