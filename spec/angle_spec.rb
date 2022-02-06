# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Angle do
  describe '::initialize' do
    context 'when initialised in degrees' do
      subject(:angle) { Angle.new(180) }

      specify { expect(angle).to eq 180.degrees }
      specify { expect(angle.radians).to eq Math::PI }
    end

    context 'when initialised in radians' do
      subject(:angle) { Angle.new(radians: Math::PI) }

      specify { expect(angle).to eq 180.degrees }
      specify { expect(angle.radians).to eq Math::PI }
    end

    context 'when initialised with a string' do
      specify { expect(Angle.new('-10')).to eq(-10.0.degrees) }
      specify { expect(Angle.new('10')).to eq(10.0.degrees) }
      specify { expect(Angle.new('-10.5')).to eq(-10.5.degrees) }
      specify { expect(Angle.new('10.5')).to eq(10.5.degrees) }
      specify { expect(Angle.new('50°')).to eq(50.0.degrees) }
      specify { expect(Angle.new('10.5 °')).to eq(10.5.degrees) }
      specify { expect(Angle.new("50° 0'")).to eq(50.0.degrees) }
      specify { expect(Angle.new("50° 30' 0\"")).to eq(50.5.degrees) }
      specify { expect(Angle.new("50° 0' 36\"")).to eq(50.01.degrees) }
    end
  end

  describe '#minutes' do
    specify { expect(Angle.new(50).minutes).to eq 0 }
    specify { expect(Angle.new("50° 0' 36\"").minutes).to eq 0 }
    specify { expect(Angle.new("50° 20' 36\"").minutes).to eq 20 }
    specify { expect(Angle.new(-50.01).minutes).to eq 0 }
  end

  describe '#seconds' do
    specify { expect(Angle.new(50).seconds).to eq 0 }
    specify { expect(Angle.new("50° 0' 36\"").seconds).to eq 36 }
    specify { expect(Angle.new("50° 20' 36\"").seconds).to eq 36 }
    specify { expect(Angle.new(-50.01).seconds).to eq 36 }
  end

  describe '#format' do
    context 'when the angle is positive' do
      subject(:positive_angle) { Angle.new("50° 30' 20\"") }

      specify { expect(positive_angle.format).to eq '50.505556' }
      specify { expect(positive_angle.format(decimals: 4)).to eq '50.5056' }
      specify { expect(positive_angle.format(sexagesimal: true)).to eq '50°30\'20"' }
      specify { expect(positive_angle.format(sexagesimal: true, sign: [nil, '-'])).to eq '50°30\'20"' }
      specify { expect(positive_angle.format(sexagesimal: true, sign: %w[N S])).to eq '50°30\'20"N' }
    end

    context 'when the angle is negative' do
      subject(:negative_angle) { Angle.new("-50° 30' 20\"") }

      specify { expect(negative_angle.format).to eq '-50.505556' }
      specify { expect(negative_angle.format(decimals: 4)).to eq '-50.5056' }
      specify { expect(negative_angle.format(sexagesimal: true)).to eq '-50°30\'20"' }
      specify { expect(negative_angle.format(sexagesimal: true, sign: [nil, '-'])).to eq '-50°30\'20"' }
      specify { expect(negative_angle.format(sexagesimal: true, sign: %w[N S])).to eq '50°30\'20"S' }
    end
  end

  describe '#<=>' do
    specify { expect(55.degrees <=> 34.degrees).to eq 1 }
    specify { expect(55.degrees <=> 55.degrees).to eq 0 }
    specify { expect(55.degrees <=> 60.degrees).to eq(-1) }
  end

  describe '#==' do
    specify { expect(55.degrees == 55.degrees).to be_truthy }
    specify { expect(55.degrees == :symbol).to be_falsey }
  end

  describe '#+' do
    specify { expect(55.degrees + 5.degrees).to eq 60.degrees }
    specify { expect(55.degrees + 5).to eq 60.degrees }
    specify { expect(55 + 5.degrees).to eq 60.0 }
  end

  describe '#abs!' do
    specify { expect(55.degrees.abs!).to eq 55.degrees }
    specify { expect(365.degrees.abs!).to eq 5.degrees }
    specify { expect(-55.degrees.abs!).to eq (360 - 55).degrees }
    specify { expect(-365.degrees.abs!).to eq 355.degrees }
  end

  describe 'Numeric to angle' do
    shared_examples_for 'converted angle' do |angle|
      specify { expect(angle).to eq(Angle.new(180.0) ) }
      specify { expect(angle).to be_an_instance_of(Angle) }
    end

    it_behaves_like 'converted angle', 180.0.degrees
    it_behaves_like 'converted angle', Math::PI.radians
  end

  describe '#longitude' do
    specify { expect(50.degrees.longitude).to eq Longitude.new(50) }
  end

  describe '#latitude' do
    specify { expect(50.degrees.latitude).to eq Latitude.new(50) }
  end

  describe 'trigometric calcs' do
    specify { expect(0.degrees.sin).to eq 0.0 }
    specify { expect(0.degrees.cos).to eq 1.0 }
    specify { expect(0.degrees.tan).to eq 0.0 }
  end
end