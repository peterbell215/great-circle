# frozen_string_literal: true

require 'spec_helper'

describe Coordinate do
  let(:coordinate) { Coordinate.new(latitude: 0, longitude: 0) }

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

  describe '#great_circle_distance_to' do
    let(:start_coordinate) { Coordinate.new(latitude: 10, longitude: 20) }
    let(:end_coordinate) { Coordinate.new(latitude: 30, longitude: 40) }

    before { allow(Vincenty).to receive(:great_circle_distance) }

    it 'calls the vincenty formulae to calculate the great circle distances' do
      start_coordinate.great_circle_distance_to(end_coordinate)

      expect(Vincenty).to have_received(:great_circle_distance).with(10, 20, 30, 40)
    end
  end

  describe '#initial_bearing_to' do
    it 'calls the vincenty formulae to calculate the initial bearing' do
      expect(Vincenty).to receive(:initial_bearing).with(10, 20, 30, 40)
      start_coordinate = Coordinate.new(latitude: 10, longitude: 20)
      end_coordinate = Coordinate.new(latitude: 30, longitude: 40)
      start_coordinate.initial_bearing_to(end_coordinate)
    end
  end

  describe '#final_bearing_from' do
    it 'calls the vincenty formulae to calculate the final bearing' do
      expect(Vincenty).to receive(:final_bearing).with(10, 20, 30, 40)
      start_coordinate = Coordinate.new(latitude: 10, longitude: 20)
      end_coordinate = Coordinate.new(latitude: 30, longitude: 40)
      end_coordinate.final_bearing_from(start_coordinate)
    end
  end
end
