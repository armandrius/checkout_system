# frozen_string_literal: true

class ExitView
  def initialize(total)
    @total = total
  end

  def render
    puts "Thanks for visiting! Your final total is #{formatted_total}."
  end

  private

  def formatted_total
    FormattedTotalPartialView.new(@total).render
  end
end
