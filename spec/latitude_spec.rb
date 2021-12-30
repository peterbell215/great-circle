# frozen_string_literal: true

require 'spec_helper'

describe Latitude do
  describe '::initialize' do
    context 'when initialised in degrees' do
      subject(:latitude) { Latitude.new(180) }

      specify { expect(latitude).to eq 180.degrees }
      specify { expect(latitude.radians).to eq Math::PI }
    end

    context 'when initialised with a string' do
      specify { expect(Latitude.new('10.5 N')).to eq(10.5.degrees) }
      specify { expect(Latitude.new('10.5 S')).to eq(-10.5.degrees) }
      specify { expect(Latitude.new('  10.5   N  ')).to eq(10.5.degrees) }
      specify { expect(Latitude.new('10°30\'0" S')).to eq(-10.5.degrees) }
      specify { expect { Latitude.new('10 E') }.to raise_error(ArgumentError) }
      specify { expect { Latitude.new('10 W') }.to raise_error(ArgumentError) }
    end
  end
end
