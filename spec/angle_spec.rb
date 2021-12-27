# frozen_string_literal: true

require 'spec_helper'

describe Angle do
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
  end

  describe 'Numeric to angle' do
    shared_examples_for 'converted angle' do |angle|
      specify { expect(angle).to eq(Angle.new(180.0) ) }
      specify { expect(angle).to be_an_instance_of(Angle) }
    end

    it_behaves_like 'converted angle', 180.0.degrees
    it_behaves_like 'converted angle', Math::PI.radians
  end
end