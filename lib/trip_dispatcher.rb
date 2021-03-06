# frozen_string_literal: true

require 'csv'
require 'time'

require_relative 'passenger'
require_relative 'trip'

module RideShare
  class TripDispatcher
    attr_reader :drivers, :passengers, :trips

    def initialize(directory: './support')
      @passengers = Passenger.load_all(directory: directory)
      @trips = Trip.load_all(directory: directory)
      @drivers = Driver.load_all(directory: directory)
      connect_trips
    end

    def find_passenger(id)
      Passenger.validate_id(id)
      return @passengers.find { |passenger| passenger.id == id }
    end

    def find_driver(id)
      Driver.validate_id(id)
      return @drivers.find { |driver| driver.id == id }
    end

    def find_available_driver
      return @drivers.find { |driver| driver.status == :AVAILABLE }
    end

    def request_trip(passenger_id)
      assigned_driver = find_available_driver
      return nil if assigned_driver.nil?

      new_passenger = find_passenger(passenger_id)
      new_trip = RideShare::Trip.new(
        id: @trips.length + 1,
        driver: assigned_driver,
        passenger: new_passenger,
        start_time: Time.now,
        end_time: nil,
        rating: nil,
        cost: nil
      )

      assigned_driver.trip_status_updating(new_trip)
      new_passenger.add_trip(new_trip)
      @trips << new_trip

      return new_trip

    end

    def inspect
      # Make puts output more useful
      return "#<#{self.class.name}:0x#{object_id.to_s(16)} \
              #{trips.count} trips, \
              #{drivers.count} drivers, \
              #{passengers.count} passengers>"
    end

    private

    def connect_trips
      @trips.each do |trip|
        passenger = find_passenger(trip.passenger_id)
        driver = find_driver(trip.driver_id)
        trip.connect(passenger, driver)
      end

      return trips
    end
  end
end
