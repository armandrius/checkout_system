# frozen_string_literal: true

class HowManyView
  def render
    print 'How many? '
    gets.strip.to_i
  end
end
