# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Longitude do
  describe '::initialize' do
    context 'when initialised in degrees' do
      subject(:longitude) { Longitude.new(180) }

      specify { expect(longitude).to eq 180.degrees }
      specify { expect(longitude.radians).to eq Math::PI }
    end

    context 'when initialised with a string' do
      specify { expect(Longitude.new('10.5 E')).to eq(10.5.degrees) }
      specify { expect(Longitude.new('10.5 W')).to eq(-10.5.degrees) }
      specify { expect(Longitude.new('  10.5   E  ')).to eq(10.5.degrees) }
      specify { expect(Longitude.new('10°30\'0" W')).to eq(-10.5.degrees) }
      specify { expect { Longitude.new('10 N') }.to raise_error(ArgumentError) }
      specify { expect { Longitude.new('10 S') }.to raise_error(ArgumentError) }
    end
  end
end



