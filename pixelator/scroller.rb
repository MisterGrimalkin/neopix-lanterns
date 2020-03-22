require_relative '../lib/color_tools'

class Scroller
  include ColorTools

  def initialize
    @over_sample = 1
    @offset = 0
    @period = nil
    @effective_period = nil
    @last_updated = nil
  end

  attr_reader :offset, :period, :effective_period, :last_updated, :over_sample

  def over_sample=(value)
    @over_sample = value
    @offset = 0
    start period if last_updated
  end

  def start(scroll_period)
    @period = scroll_period.to_f
    @effective_period = scroll_period.to_f / @over_sample
    @last_updated = Time.now
    self
  end

  def resume
    @last_updated = Time.now
  end

  def stop
    @last_updated = nil
    self
  end

  def check_and_update
    update Time.now - last_updated if last_updated
  end

  def update(elapsed_seconds)
    return unless period && last_updated

    if elapsed_seconds >= effective_period.abs
      @offset += (elapsed_seconds / effective_period)
      @last_updated = Time.now
    end
  end

  def scroll(pattern)
    over_sampled = [ColorA.new] * (pattern.size * over_sample)
    pixel = 0
    pattern.each do |color_a|
      over_sample.times do
        p = (pixel + offset) % over_sampled.size
        over_sampled[p] = color_a
        pixel += 1
      end
    end

    return over_sampled if over_sample == 1

    result = [ColorA.new] * pattern.size
    average_buffer = []
    pixel = 0
    over_sampled.each do |color_a|
      average_buffer << color_a
      if average_buffer.size == over_sample
        result[pixel] = mix_colors(average_buffer)
        average_buffer = []
        pixel += 1
      end
    end
    result
  end
end