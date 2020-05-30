require_relative '../neo_pixel'
require_relative '../../lib/utils'

class TextNeoPixel < NeoPixel
  include Utils

  def initialize(pixel_count:, mode: :rgb)
    super(pixel_count: pixel_count, mode: mode)
    @shows_to_ignore = 3
  end

  def show(buffer)
    unless shows_to_ignore <= 0
      self.shows_to_ignore = shows_to_ignore - 1
      return
    end
    output = ''
    buffer.each_slice(3) do |rgb|
      output << pixel_symbol(*rgb)
    end
    print "\r[#{output}]"
  end

  private

  attr_accessor :shows_to_ignore

  def pixel_symbol(r, g, b)
    has_red = r > 64
    has_green = g > 64
    has_blue = b > 64

    non_zero_count = [r,g,b].select{|c| c.to_f > 0 }.size
    non_zero_average = non_zero_count.zero? ? 0 : [r,g,b].sum / non_zero_count

    if non_zero_average < 85
      dim = true
      bold = false
    elsif non_zero_average < 170
      dim = false
      bold = false
    else
      dim = false
      bold = true
    end

    color = if has_red
              if has_green
                if has_blue
                  :white
                else
                  :yellow
                end
              else
                if has_blue
                  :purple
                else
                  :red
                end
              end
            else
              if has_green
                if has_blue
                  :cyan
                else
                  :green
                end
              else
                if has_blue
                  :blue
                else
                  :black
                end
              end
            end

    colorize '■', color, bold: bold, dim: dim
  end

end