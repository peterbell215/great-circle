# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Latitude do
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

    context 'when initialised with a string in SCT file format' do
      let(:angle) { (54.0 + 1.0/60.0 + 12.3/3600.0).degrees }

      specify { expect(Latitude.new('N054.1.12.300')).to eq(angle) }
      specify { expect(Latitude.new('S054.1.12.300')).to eq(-angle) }
      specify { expect { Latitude.new('E054.1.12.300') }.to raise_error(ArgumentError) }
      specify { expect { Latitude.new('W054.1.12.300') }.to raise_error(ArgumentError) }
    end
  end
end
