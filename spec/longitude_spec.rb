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

    context 'when initialised with a string in SCT file format' do
      let(:angle) { (54.0 + 1.0/60.0 + 12.3/3600.0).degrees }

      specify { expect(Longitude.new('E054.1.12.300')).to eq(angle) }
      specify { expect(Longitude.new('W054.1.12.300')).to eq(-angle) }
      specify { expect { Longitude.new('N054.1.12.300') }.to raise_error(ArgumentError) }
      specify { expect { Longitude.new('S054.1.12.300') }.to raise_error(ArgumentError) }
    end
  end
end



