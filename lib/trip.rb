require 'csv'
require 'time'

require_relative 'csv_record'

module RideShare
  class Trip < CsvRecord
    attr_reader :id, :passenger, :passenger_id, :start_time, :end_time, :cost, :rating, :driver_id, :driver

    def initialize(
          id:,
          passenger: nil,
          passenger_id: nil,
          start_time:,
          end_time:,
          cost: nil,
          rating:,
          driver_id: nil,
          driver: nil
        )
      super(id)

      if passenger
        @passenger = passenger
        @passenger_id = passenger.id

      elsif passenger_id
        @passenger_id = passenger_id

      else
        raise ArgumentError, 'Passenger or passenger_id is required'
      end

      if driver
        @driver = driver
        @driver_id = driver.id

      elsif driver_id
        @driver_id = driver_id

      else
        raise ArgumentError, 'Driver or Driver_id is required'
      end

      unless end_time.nil?
        if start_time > end_time
          raise ArgumentError, "Your start time#{start_time} is later than your end time#{end_time} "
        end
      end

      @start_time = start_time
      @end_time = end_time

      @cost = cost
      @rating = rating

      unless @rating.nil?
        if @rating > 5 || @rating < 1
          raise ArgumentError, "Invalid rating #{@rating}"
        end
      end
    end

    def inspect
      # Prevent infinite loop when puts-ing a Trip
      # trip contains a passenger contains a trip contains a passenger...
      "#<#{self.class.name}:0x#{object_id.to_s(16)} " +
        "id=#{id.inspect} " +
        "passenger_id=#{passenger&.id.inspect} " +
        "start_time=#{start_time} " +
        "end_time=#{end_time} " +
        "cost=#{cost} " +
        "rating=#{rating} " +
        "driver_id = #{driver&.id.inspect}>"
    end

    def connect(passenger, driver)
      @passenger = passenger
      @driver = driver
      driver.add_trip(self)
      passenger.add_trip(self)
    end

    def trip_duration
      if @end_time.nil?
        return 0
      else
        return  @end_time - @start_time
      end
    end

    private

    def self.from_csv(record)
      return new(
        id: record[:id],
        passenger_id: record[:passenger_id],
        start_time: Time.parse(record[:start_time]),
        end_time: Time.parse(record[:end_time]),
        cost: record[:cost],
        rating: record[:rating],
        driver_id: record[:driver_id]
      )
    end
  end
end


