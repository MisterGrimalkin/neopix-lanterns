require_relative '../../pixelator/pixel_group'
require_relative '../../pixelator/pixelator'
require_relative '../../neo_pixel/neo_pixel'
require_relative '../../support/color_constants'

require 'byebug'

RSpec.describe PixelGroup do

  let(:neo_pixel) { NeoPixel.new(8) }

  let(:pixelator) { Pixelator.new neo_pixel }

  let(:blk) { Color.new }
  let(:red) { Color.new 200,0,0 }
  let(:dk_red) { Color.new 100,0,0 }
  let(:blue) { Color.new 0,0,200 }
  let(:dk_blue) { Color.new 0,0,100 }

  subject(:group) { pixelator.group new_group: (2..5) }

  it '.initializes correctly' do
    expect(group).to eq(pixelator[:new_group])
    expect(group).to be_a PixelGroup
    expect(group.pixels.size).to eq 4
  end

  it 'set color and brightness' do
    group.set red, 1
    pixelator.render
    expect(neo_pixel.contents)
        .to eq [blk, blk, red, red, red, red, blk, blk]

    group.brightness = 0.5
    pixelator.render
    expect(neo_pixel.contents)
        .to eq [blk, blk, dk_red, dk_red, dk_red, dk_red, blk, blk]

    group.color = blue
    pixelator.render
    expect(neo_pixel.contents)
        .to eq [blk, blk, dk_blue, dk_blue, dk_blue, dk_blue, blk, blk]
  end

  it 'draws a gradient' do
    group.gradient red: [180, 0], green: [10, 100], blue: [7, 10]
    pixelator.render
    expect(neo_pixel.contents)
    .to eq([blk, blk,
           Color.new(180, 10, 7),
           Color.new(120, 40, 8),
           Color.new(60, 70, 9),
           Color.new(0, 100, 10),
           blk, blk])
  end

end