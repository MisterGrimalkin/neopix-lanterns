require './components/assets'
require './components/neopixel/fps_meter'
require './components/osc/osc_control_hooks'
require './lib/colours'
require './lib/utils'

module Fitl
  class Pixelator
    include Colours
    include Utils

    def initialize(neo_pixel:, mode: :layer, frame_rate: 30, osc_control_port: nil, assets: Assets.new)
      @neo_pixel = neo_pixel
      @mode = mode
      @frame_rate = frame_rate
      @assets = assets

      OscControlHooks.new(self, port: osc_control_port, assets: assets).start if osc_control_port

      @base = [BLACK] * pixel_count
      @started = false
      clear
    end

    def pixel_count
      neo_pixel.pixel_count
    end

    attr_reader :neo_pixel, :frame_rate, :started, :base, :assets

    attr_accessor :mode
    private :mode=

    Assets::MEDIA_TYPES.each do |type|
      define_method "#{type}_mode" do
        self.mode = type
        clear
        self
      end

      define_method "#{type}_mode?" do
        self.mode == type
      end
    end

    attr_accessor :media
    private :media=
    alias_method :get, :media

    def clear
      self.media = assets.send("new_#{mode}")
      render
      self
    end

    def build(name, config = {})
      self.media = assets.send("build_#{mode}", name, config)
    end

    def load_file(name)
      self.media = assets.send("load_#{mode}", name)
    end

    def save_file
      assets.send("save_#{mode}", media)
    end

    def buffer
      media.render_over(base)
    end

    def render
      neo_pixel.write(buffer).render
    end

    def render_period
      1.0 / frame_rate
    end

    def start(period = render_period)
      raise AlreadyStarted if started

      @started = true

      @render_thread = Thread.new do
        while started
          ticker = Time.now

          media.update
          render

          if (elapsed = Time.now - ticker) < period
            sleep period - elapsed
          end
        end
      end

      self
    end

    def stop
      return unless started

      @started = false
      @render_thread.join

      self
    end

    def attach_meter
      neo_pixel.fps_meter = FpsMeter.new(frame_rate)
    end

    def inspect
      "<Pixelator[#{started ? '▶' : '■'}] adapter:#{neo_pixel} mode:#{mode}>"
    end

    def filename(name)
      assets.media_filename(mode, name)
    end

    AlreadyStarted = Class.new(StandardError)
  end
end

