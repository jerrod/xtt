module ActiveSupport #:nodoc:
  class TimeZone
    def utc_offset_string
      is_negative = @utc_offset < 0
      seconds = @utc_offset.abs
      hours   = seconds / 1.hour
      seconds = seconds % 1.hour
      minutes = seconds / 1.minute
      (is_negative ? '-' : '+') + ('%02d:%02d' % [hours, minutes])
    end
  end

  # A Time-like class that can represent a time in any time zone. Necessary because standard Ruby Time instances are 
  # limited to UTC and the system's ENV['TZ'] zone
  class TimeWithZone
    # Changes the time zone without converting the time
    def change_time_zone(new_zone)
      time.change_time_zone(new_zone)
    end
  end

  module CoreExtensions #:nodoc:
    module Time #:nodoc:
      # Methods for creating TimeWithZone objects from Time instances
      module Zones
        # Replaces the existing zone; leaves time values intact. Examples:
        #
        #   t = Time.utc(2000)            # => Sat Jan 01 00:00:00 UTC 2000
        #   t.change_time_zone('Alaska')  # => Sat, 01 Jan 2000 00:00:00 AKST -09:00
        #   t.change_time_zone('Hawaii')  # => Sat, 01 Jan 2000 00:00:00 HST -10:00
        #
        # Note the difference between this method and #in_time_zone: #in_time_zone does a calculation to determine
        # the simultaneous time in the supplied zone, whereas #change_time_zone does no calculation; it just
        # "dials in" a new time zone for +self+
        def change_time_zone(zone)
          ActiveSupport::TimeWithZone.new(nil, get_zone(zone), self)
        end
      end
    end
  end
end