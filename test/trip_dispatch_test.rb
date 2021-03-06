# frozen_string_literal: true

require_relative 'test_helper'
require 'time'

TEST_DATA_DIRECTORY = 'test/test_data'

describe 'TripDispatcher class' do
  def build_test_dispatcher
    return RideShare::TripDispatcher.new(
      directory: TEST_DATA_DIRECTORY
    )
  end

  describe 'Initializer' do
    it 'is an instance of TripDispatcher' do
      dispatcher = build_test_dispatcher
      expect(dispatcher).must_be_kind_of RideShare::TripDispatcher
    end

    it 'establishes the base data structures when instantiated' do
      dispatcher = build_test_dispatcher
      %i[trips passengers drivers].each do |prop|
        expect(dispatcher).must_respond_to prop
      end

      expect(dispatcher.trips).must_be_kind_of Array
      expect(dispatcher.passengers).must_be_kind_of Array
      expect(dispatcher.drivers).must_be_kind_of Array
    end

    it 'loads the development data by default' do
      # Count lines in the file, subtract 1 for headers
      trip_count = `wc -l 'support/trips.csv'`.split(' ').first.to_i - 1

      dispatcher = RideShare::TripDispatcher.new

      expect(dispatcher.trips.length).must_equal trip_count
    end
  end

  describe 'passengers' do
    describe 'find_passenger method' do
      before do
        @dispatcher = build_test_dispatcher
      end

      it 'throws an argument error for a bad ID' do
        expect { @dispatcher.find_passenger(0) }.must_raise ArgumentError
      end

      it 'finds a passenger instance' do
        passenger = @dispatcher.find_passenger(2)
        expect(passenger).must_be_kind_of RideShare::Passenger
      end
    end

    describe 'Passenger & Trip loader methods' do
      before do
        @dispatcher = build_test_dispatcher
      end

      it 'accurately loads passenger information into passengers array' do
        first_passenger = @dispatcher.passengers.first
        last_passenger = @dispatcher.passengers.last

        expect(first_passenger.name).must_equal 'Passenger 1'
        expect(first_passenger.id).must_equal 1
        expect(last_passenger.name).must_equal 'Passenger 8'
        expect(last_passenger.id).must_equal 8
      end

      it 'connects trips and passengers' do
        dispatcher = build_test_dispatcher
        dispatcher.trips.each do |trip|
          expect(trip.passenger).wont_be_nil
          expect(trip.passenger.id).must_equal trip.passenger_id
          expect(trip.passenger.trips).must_include trip
        end
      end
    end
  end

  describe 'drivers' do
    describe 'find_driver method' do
      before do
        @dispatcher = build_test_dispatcher
      end

      it 'throws an argument error for a bad ID' do
        expect { @dispatcher.find_driver(0) }.must_raise ArgumentError
      end

      it 'finds a driver instance' do
        driver = @dispatcher.find_driver(2)
        expect(driver).must_be_kind_of RideShare::Driver
      end
    end

    describe 'Driver & Trip loader methods' do
      before do
        @dispatcher = build_test_dispatcher
      end

      it 'accurately loads driver information into drivers array' do
        first_driver = @dispatcher.drivers.first
        last_driver = @dispatcher.drivers.last

        expect(first_driver.name).must_equal 'Driver 1 (unavailable)'
        expect(first_driver.id).must_equal 1
        expect(first_driver.status).must_equal :UNAVAILABLE
        expect(last_driver.name).must_equal 'Driver 3 (no trips)'
        expect(last_driver.id).must_equal 3
        expect(last_driver.status).must_equal :AVAILABLE
      end

      it 'connects trips and drivers' do
        dispatcher = build_test_dispatcher
        dispatcher.trips.each do |trip|
          expect(trip.driver).wont_be_nil
          expect(trip.driver.id).must_equal trip.driver_id
          expect(trip.driver.trips).must_include trip
        end
      end
    end
  end

  describe 'trip' do
    before do
      @dispatcher = build_test_dispatcher
    end

    it 'accurately loads trip information into trips array' do
      first_trip = @dispatcher.trips.first
      last_trip = @dispatcher.trips.last

      expect(first_trip.id).must_equal 1
      expect(first_trip.driver_id).must_equal 1
      expect(first_trip.passenger_id).must_equal 1
      expect(first_trip.start_time).must_equal Time.parse('2018-05-25 11:52:40 -0700')
      expect(first_trip.end_time).must_equal Time.parse('2018-05-25 12:25:00 -0700')
      expect(first_trip.cost).must_equal 10
      expect(first_trip.rating).must_equal 5
      expect(last_trip.id).must_equal 5
      expect(last_trip.driver_id).must_equal 2
      expect(last_trip.passenger_id).must_equal 6
      expect(last_trip.start_time).must_equal Time.parse('2018-08-05 08:58:00 -0700')
      expect(last_trip.end_time).must_equal Time.parse('2018-08-05 09:30:00 -0700')
      expect(last_trip.cost).must_equal 32
      expect(last_trip.rating).must_equal 1
    end

  end

  describe 'request_trip' do
    before do
      @dispatcher = build_test_dispatcher
    end

    it 'validates driver status' do
      assigned_driver = @dispatcher.find_available_driver
      expect(assigned_driver.name).must_equal 'Driver 2'
    end

    it 'return nil if no driver is available' do
      drivers = @dispatcher.drivers
      drivers.each do |driver|
        if driver.status == :AVAILABLE
          driver.status = :UNAVAILABLE
        end
        return drivers
      end

      assigned_driver = drivers.find_available_driver
      expect(assigned_driver).must_equal nil
    end

    #should call @dispatcher.request_trip and check that trip, driver, passenger make sense after
    it 'checks if the trip was properly created' do
      trips = @dispatcher.trips
      drivers = @dispatcher.drivers
      passengers = @dispatcher.passengers
      new_trip = @dispatcher.request_trip(8)

      expect(trips.length).must_equal 6
      expect(passengers.length).must_equal 8
      expect(new_trip.driver.status).must_equal :UNAVAILABLE
      expect(new_trip.id).must_equal 6
      expect(new_trip.driver).must_be_kind_of RideShare::Driver
      expect(new_trip.passenger).must_be_kind_of RideShare::Passenger
      expect(new_trip.end_time).must_equal nil
      expect(new_trip.rating).must_equal nil
      expect(new_trip.cost).must_equal nil

    end
  end
end
