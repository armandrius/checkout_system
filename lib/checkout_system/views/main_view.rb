# frozen_string_literal: true

class MainView
  def initialize(total)
    @total = total
  end

  def render
    puts "\nYour basket total is #{formatted_total}. What do you want to do?"
    puts 'L: Buy products through a list of codes, B: Buy separate products by quantity,'
    puts 'D: Add discounts, E: Empty your basket, Q: Quit'

    print '> '
    gets.strip.upcase
  end

  private

  def formatted_total
    FormattedTotalPartialView.new(@total).render
  end
end
