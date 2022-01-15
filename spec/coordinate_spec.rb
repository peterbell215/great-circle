# frozen_string_literal: true

require 'spec_helper'
require 'great-circle-test-helpers'

RSpec.describe Coordinate do
  let(:coordinate) { Coordinate.new(latitude: 0, longitude: 0) }

  # rubocop: disable RSpec/MultipleMemoizedHelpers
  # rubocop: disable Naming/VariableNumber easier to understand which numbers are minus this way
  shared_context 'with common coordinates for testing' do
    let(:coord_50_minus5) { Coordinate.new(latitude: 50, longitude: -5) }
    let(:coord_58_minus3) { Coordinate.new(latitude: 58, longitude: -3) }
    let(:coord_minus58_3) { Coordinate.new(latitude: -58, longitude: 3) }
    let(:coord_10_10) { Coordinate.new(latitude: 10.degrees, longitude: 10.degrees) }
    let(:coord_50_50) { Coordinate.new(latitude: 50.degrees, longitude: 50.degrees) }
  end
  # rubocop: enable RSpec/MultipleMemoizedHelpers
  # rubocop: enable Naming/VariableNumber

  describe 'initialization' do
    it 'initializes object with provided parameters' do
      new_coordinate = Coordinate.new(latitude: 10, longitude: 20)
      expect(new_coordinate.latitude).to eq(10.degrees)
      expect(new_coordinate.longitude).to eq(20.degrees)
    end
  end

  describe ':eql?' do
    subject { Coordinate.new(latitude: 54.320, longitude: 3.03) }

    let(:same_coordinate) { Coordinate.new(latitude: 54.320, longitude: 3.03) }
    let(:different_latitude) { Coordinate.new(latitude: 54.0, longitude: 3.03) }
    let(:different_longitude) { Coordinate.new(latitude: 54.320, longitude: 3.00) }

    it { is_expected.to be_eql(same_coordinate) }
    it { is_expected.not_to be_eql(different_latitude) }
    it { is_expected.not_to be_eql(different_longitude) }
  end

  describe '#new_position' do
    include_context 'with common coordinates for testing'

    describe 'new positions from origin' do
      let(:origin) { Coordinate.new(latitude: 0, longitude: 0) }
      let(:one_nm_n_or_origin) { Coordinate.new(latitude: '0°1\'0" N', longitude: 0) }
      let(:one_nm_s_or_origin) { Coordinate.new(latitude: '0°1\'0" S', longitude: 0) }
      let(:one_nm_e_or_origin) { Coordinate.new(latitude: 0, longitude: '0°1\'0" E') }

      specify do
        expect(origin.new_position(heading: 180.0.degrees, distance: 1.0)).to be_very_close_to one_nm_s_or_origin
      end
    end

    describe 'from two points on the globe' do
      shared_examples_for 'calculation based on heading and distance' do
        subject(:new_position) { start_position.new_position(distance: distance, heading: heading) }

        let(:distance) { start_position.distance_to(end_position) }
        let(:heading) { start_position.initial_heading_to(end_position) }

        specify { expect(new_position.latitude.radians).to be_within(0.3).of(end_position.latitude.radians) }
        specify { expect(new_position.longitude.radians).to be_within(0.3).of(end_position.longitude.radians) }
      end

      it_behaves_like 'calculation based on heading and distance' do
        let(:start_position) { coord_50_minus5 }
        let(:end_position) { coord_58_minus3 }
      end

      it_behaves_like 'calculation based on heading and distance' do
        let(:start_position) { coord_50_minus5 }
        let(:end_position) { coord_58_minus3 }
      end

      it_behaves_like 'calculation based on heading and distance' do
        let(:start_position) { coord_58_minus3 }
        let(:end_position) { coord_50_minus5 }
      end
    end
  end

  describe 'Vincenty and Haversine calculations' do
    include_context 'with common coordinates for testing'

    shared_examples_for 'Vincenty calculations' do |distance, initial_heading_to, final_heading_to|
      specify { expect(start_position.distance_to(final_position)).to be_within(0.001).of(distance) }

      # Haversine is less accurate.  Check the error is less than 1%.
      specify { expect(start_position.distance_to(final_position, algorithm: :haversine)).to be_within(0.01*distance).of(distance) }

      specify { expect(start_position.initial_heading_to(final_position).degrees).to be_within(0.001).of(initial_heading_to) }
      specify { expect(start_position.final_heading_from(final_position).degrees).to be_within(0.001).of(final_heading_to) }
    end

    it_behaves_like 'Vincenty calculations', 485.927, 7.575056, 9.197103 do
      let(:start_position) { coord_50_minus5 }
      let(:final_position) { coord_58_minus3 }
    end

    it_behaves_like 'Vincenty calculations', 6_476.511, 175.531128, 174.579117 do
      let(:start_position) { coord_50_minus5 }
      let(:final_position) { coord_minus58_3 }
    end

    it_behaves_like 'Vincenty calculations', 3_109.25, 31.830619, 53.758428 do
      let(:start_position) { coord_10_10 }
      let(:final_position) { coord_50_50 }
    end

    describe 'caching mechanism' do
      before { allow(Vincenty).to receive(:iterative_solver).and_call_original }

      # rubocop: disable RSpec/MultipleExpectations; want to test that call to solution_set is only made once.
      it 'only does the Vincenty calculation once' do
        expect(coord_50_minus5.distance_to(coord_58_minus3)).to be_within(0.001).of(485.927)
        expect(coord_50_minus5.initial_heading_to(coord_58_minus3).degrees).to be_within(0.001).of(7.575056)
        expect(coord_50_minus5.final_heading_from(coord_58_minus3).degrees).to be_within(0.001).of(9.197103)

        expect(Vincenty).to have_received(:iterative_solver).once
      end
      # rubocop: enable RSpec/MultipleExpectations
    end
  end
end
