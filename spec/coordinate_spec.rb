# frozen_string_literal: true

require 'spec_helper'

describe Coordinate do
  let(:coordinate) { Coordinate.new(latitude: 0, longitude: 0) }

  # rubocop: disable RSpec/MultipleMemoizedHelpers
  # rubocop: disable Naming/VariableNumber easier to understand which numbers are minus this way
  shared_context 'with common coordinates for testing' do
    let(:coord_50_minus5) { Coordinate.new(latitude: 50, longitude: -5) }
    let(:coord_58_minus3) { Coordinate.new(latitude: 58, longitude: -3) }
    let(:coord_minus58_3) { Coordinate.new(latitude: -58, longitude: 3) }
    let(:coord_10_10) { Coordinate.new(latitude: 10, longitude: 10) }
    let(:coord_50_50) { Coordinate.new(latitude: 50, longitude: 50) }
  end
  # rubocop: enable RSpec/MultipleMemoizedHelpers
  # rubocop: enable Naming/VariableNumber

  describe 'initialization' do
    it 'initializes object with provided parameters' do
      new_coordinate = Coordinate.new(latitude: 10,
                                      longitude: 20)
      expect(new_coordinate.latitude).to eq(10)
      expect(new_coordinate.longitude).to eq(20)
    end
  end

  describe 'coordinate parsing' do
    it 'accepts a simple string for latitudes and longitudes' do
      coordinate.latitude = '-10'
      coordinate.longitude = '10'
      expect(coordinate.latitude).to eq(-10.0)
      expect(coordinate.longitude).to eq(10.0)
    end

    it 'accepts a decimal string for latitudes and longitudes' do
      coordinate.latitude = '-10.5'
      coordinate.longitude = '10.5'
      expect(coordinate.latitude).to eq(-10.5)
      expect(coordinate.longitude).to eq(10.5)
    end

    describe 'with cardinal directions' do
      it 'saves the latitude if given N as cardinal direction' do
        coordinate.latitude = '10.5 N'
        expect(coordinate.latitude).to eq(10.5)
      end

      it 'makes the latitude negative if given S as a cardinal direction' do
        coordinate.latitude = '10.5 S'
        expect(coordinate.latitude).to eq(-10.5)
      end

      it 'handles spaces around things' do
        coordinate.latitude = '  10.5   N  '
        expect(coordinate.latitude).to eq(10.5)
      end

      it 'throws an exception if given E or W as a direction for latitude' do
        expect { coordinate.latitude = '10 E' }.to raise_error(ArgumentError)
        expect { coordinate.latitude = '10 W' }.to raise_error(ArgumentError)
      end

      it 'saves the longitude if given E as a cardinal direction' do
        coordinate.longitude = '10.5 E'
        expect(coordinate.longitude).to eq(10.5)
      end

      it 'makes the longitude negative if given W as a cardinal direction' do
        coordinate.longitude = '10.5 W'
        expect(coordinate.longitude).to eq(-10.5)
      end

      it 'throws an exception if given N or S as a direction for longitude' do
        expect { coordinate.longitude = '10 N' }.to raise_error(ArgumentError)
        expect { coordinate.longitude = '10 S' }.to raise_error(ArgumentError)
      end
    end

    describe 'parsing degrees minutes and seconds' do
      it 'takes simple degrees input and set as decimal' do
        coordinate.latitude = '50°'
        expect(coordinate.latitude).to eq(50.0)

        coordinate.longitude = '10.5 °'
        expect(coordinate.longitude).to eq(10.5)
      end

      it 'takes degrees and minutes' do
        coordinate.latitude = "50° 0'"
        expect(coordinate.latitude).to eq(50)

        coordinate.latitude = '50° 0′'
        expect(coordinate.latitude).to eq(50)
      end

      it 'converts minutes to 1/60ths of degrees' do
        coordinate.latitude = "50° 30'"
        expect(coordinate.latitude).to eq(50.5)
      end

      it 'takes degrees, minutes, and seconds' do
        coordinate.latitude = "50° 0' 0\""
        expect(coordinate.latitude).to eq(50)

        coordinate.latitude = "50° 0' 0″"
        expect(coordinate.latitude).to eq(50)
      end

      it 'takes degrees and seconds' do
        coordinate.latitude = '50° 0"'
        expect(coordinate.latitude).to eq(50)
      end

      it 'converts seconds to 1/60ths of minutes' do
        coordinate.latitude = "50° 0' 36\""
        expect(coordinate.latitude).to eq(50.01)
      end
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

  describe 'validation' do
    it 'is valid if given valid lat and long' do
      expect(coordinate).to be_valid
    end

    it 'is invalid unless latitude provided' do
      coordinate.latitude = nil
      expect(coordinate).not_to be_valid
    end

    it 'is invalid unless longitude provided' do
      coordinate.longitude = nil
      expect(coordinate).not_to be_valid
    end

    it 'is invalid unless latitude is between -90 and 90' do
      coordinate.latitude = -100
      expect(coordinate).not_to be_valid

      coordinate.latitude = 100
      expect(coordinate).not_to be_valid
    end

    it 'is invalid unless longitude is between -180 and 180' do
      coordinate.longitude = -190
      expect(coordinate).not_to be_valid

      coordinate.longitude = 190
      expect(coordinate).not_to be_valid
    end
  end

  describe '#new_position' do
    include_context 'with common coordinates for testing'

    shared_examples_for 'calculation based on heading and distance' do
      subject(:new_position) { start_position.new_position(distance: distance, heading: heading) }

      let(:distance) { start_position.distance_to(end_position) }
      let(:heading) { start_position.initial_heading_to(end_position) }

      specify { expect(new_position.latitude).to be_within(0.3).of(end_position.latitude) }
      specify { expect(new_position.longitude).to be_within(0.3).of(end_position.longitude) }
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

  describe 'Vincenty calculations' do
    include_context 'with common coordinates for testing'

    shared_examples_for 'Vincenty calculations' do |method, value1, value2, value3|
      specify { expect(coord_50_minus5.send(method, coord_58_minus3)).to be_within(0.001).of(value1) }
      specify { expect(coord_50_minus5.send(method, coord_minus58_3)).to be_within(0.001).of(value2) }
      specify { expect(coord_10_10.send(method, coord_50_50)).to be_within(0.001).of(value3) }
    end

    describe '#distance_to' do
      it 'returns 0 if both coordinates are equal' do
        expect(coord_50_minus5.distance_to(coord_50_minus5)).to be_zero
      end

      it_behaves_like 'Vincenty calculations', :distance_to, 485.927, 6_476.511, 3_109.25
    end

    describe '#intial_bearing' do
      it_behaves_like 'Vincenty calculations', :initial_heading_to, 7.575056, 175.531128, 31.830619
    end

    describe '#final_bearing_from' do
      it_behaves_like 'Vincenty calculations', :final_heading_from, 9.197103, 174.579117, 53.758428
    end

    describe 'caching mechanism' do
      before { allow(Vincenty).to receive(:solution_set).and_call_original }

      # rubocop: disable RSpec/MultipleExpectations; want to test that call to solution_set is only made once.
      it 'only does the Vincenty calculation once' do
        expect(coord_50_minus5.distance_to(coord_58_minus3)).to be_within(0.001).of(485.927)
        expect(coord_50_minus5.initial_heading_to(coord_58_minus3)).to be_within(0.001).of(7.575056)
        expect(coord_50_minus5.final_heading_from(coord_58_minus3)).to be_within(0.001).of(9.197103)

        expect(Vincenty).to have_received(:solution_set).once
      end
      # rubocop: enable RSpec/MultipleExpectations
    end
  end
end
