require_relative '../../fitl/pixelator/envelope'

require 'ostruct'

require 'byebug'

RSpec.describe Envelope do

  let(:target) { OpenStruct.new(dial: 0) }
  let(:method) { :dial= }

  let(:attack) { 4 }
  let(:sustain) { 2 }
  let(:release) { 1 }
  let(:loop) { false }
  let(:enable_thread) { false }

  subject do
    Envelope.new target, method, off: 4, max: 8, loop: loop,
                 attack_time: attack, attack_profile: {0.25 => 0.25, 0.75 => 1.0},
                 sustain_time: sustain, sustain_profile: 0.75,
                 release_time: release, release_profile: {0.5 => 0.25, 1.0 => 0.125},
                 enable_thread: enable_thread
  end

  it 'generates curves' do
    expect(subject.send(:attack_curve)).to eq [[0.0, 4.0], [1.0, 2.0], [3.0, 8.0], [4.0, 6.0]]
    expect(subject.send(:release_curve)).to eq [[0.0, 6.0], [0.5, 2.0], [1.0, 1.0]]
  end

  it '.value_at' do
    expect(subject.value_at -1).to eq 4
    expect(subject.value_at 0).to eq 4
    expect(subject.value_at 0.5).to eq 3
    expect(subject.value_at 1).to eq 2
    expect(subject.value_at 2).to eq 5
    expect(subject.value_at 3).to eq 8
    expect(subject.value_at 3.5).to eq 7
    expect(subject.value_at 4).to eq 6
    expect(subject.value_at 5).to eq 6
    expect(subject.value_at 6).to eq 6
    expect(subject.value_at 6.25).to eq 4
    expect(subject.value_at 6.5).to eq 2
    expect(subject.value_at 6.75).to eq 1.5
    expect(subject.value_at 7).to eq 1
    expect(subject.value_at 8).to eq 1
    expect(subject.value_at 9).to eq 1
  end

  context 'when looping is enabled' do
    let(:loop) { true }

    it 'generates curves' do
      expect(subject.send(:attack_curve)).to eq [[0.0, 4.0], [1.0, 2.0], [3.0, 8.0], [4.0, 6.0]]
      expect(subject.send(:release_curve)).to eq [[0.0, 6.0], [0.5, 2.0], [1.0, 4.0]]
    end

    it '.value_at' do
      expect(subject.value_at -1).to eq 4
      expect(subject.value_at 0).to eq 4
      expect(subject.value_at 0.5).to eq 3
      expect(subject.value_at 1).to eq 2
      expect(subject.value_at 2).to eq 5
      expect(subject.value_at 3).to eq 8
      expect(subject.value_at 3.5).to eq 7
      expect(subject.value_at 4).to eq 6
      expect(subject.value_at 5).to eq 6
      expect(subject.value_at 6).to eq 6
      expect(subject.value_at 6.25).to eq 4
      expect(subject.value_at 6.5).to eq 2
      expect(subject.value_at 6.75).to eq 3
      expect(subject.value_at 7).to eq 4

      expect(subject.value_at 8).to eq 2
      expect(subject.value_at 9).to eq 5
      expect(subject.value_at 12).to eq 6
      expect(subject.value_at 13.5).to eq 2

      expect(subject.value_at 17.5).to eq 7
      expect(subject.value_at 19.5).to eq 6

      expect(subject.value_at 24).to eq 8
      expect(subject.value_at 28).to eq 4
    end
  end

  context 'when thread is enabled' do
    let(:attack) { 1 }
    let(:sustain) { 0.5 }
    let(:release) { 0.25 }
    let(:enable_thread) { true }

    it 'updates the object' do
      expect(target.dial).to eq 0.0
      sleep 0.1
      expect(target.dial).to eq 0.0

      subject.start
      expect(target.dial).to be_within(0.01).of 4.0

      sleep 0.5
      expect(target.dial).to be_between(2, 8)

      sleep 0.75
      expect(target.dial).to eq 6

      subject.stop

      sleep 0.75
      expect(target.dial).to eq 6
    end
  end

  context 'default envelope' do
    subject do
      Envelope.new target, :dial=
    end
    it 'initialises' do
      expect(subject.send(:attack_curve)).to eq [[0.0, 0.0], [1.0, 1.0]]
      expect(subject.sustain_value).to eq 1.0
      expect(subject.send(:release_curve)).to eq [[0.0, 1.0], [1.0, 0.0]]
      expect(subject.value_at 0.5).to eq 0.5
      expect(subject.value_at 1.5).to eq 1.0
      expect(subject.value_at 2.5).to eq 0.5
      expect(subject.value_at 3.5).to eq 0.0
    end
  end

  context 'given no clue' do
    subject do
      Envelope.new target
    end
    it 'raises an error' do
      expect { subject }.to raise_error(Unclear)
    end
  end

  context 'given a proc' do
    subject do
      Envelope.new(attack_time: 0.1, max: 5) { |value| print "[#{value}]" }
    end
    it 'runs the proc' do
      subject.start
      sleep 0.2
      expect { subject.update }.to output('[5.0]').to_stdout
    end
  end

end