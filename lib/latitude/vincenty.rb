# frozen_string_literal: true

require_relative 'lat_long_calcs'

# Implements great circle calculations.  Thanks to http://www.movable-type.co.uk/scripts/latlong-vincenty.html
module Vincenty
  extend self

  include LatLongCalcs

  VincentySolution = Struct.new(:initial_bearing, :final_bearing, :distance, keyword_init: true)

  # in meters
  WGS84_A = 6_378_137.0
  WGS84_B = 6_356_752.314245

  def solution_set(start_lat, start_long, end_lat, end_long)
    phi1 = to_radians(start_lat)
    lambda1 = to_radians(start_long)
    phi2 = to_radians(end_lat)
    lambda2 = to_radians(end_long)

    iterative_solver(phi1, lambda1, phi2, lambda2)
  end

  private

  # rubocop: disable Metrics/MethodLength
  # rubocop: disable Metrics/AbcSize
  def iterative_solver(phi1, lambda1, phi2, lambda2)
    delta_lambda = lambda2 - lambda1 # difference in longitude on an auxiliary sphere
    sin_u1, cos_u1 = get_trig_trio(phi1)
    sin_u2, cos_u2 = get_trig_trio(phi2)

    lam = delta_lambda

    # A comment that might one day end up on Medium :-)
    #
    # This loop is a mess.  The problem is that for performance reasons so many of the values calculated in the loop
    # are then after the loop to do the final calculations.  So I could either declare some ten intermediate
    # loop values before the start of the loop so their scope is still there after existing the loop, or insert a next
    # in the middle of the loop for the standard case, and fall through to the final calculation and a return.
    100.times do
      sin_lam = Math.sin(lam)
      cos_lam = Math.cos(lam)

      sin_sigma = Math.sqrt((cos_u2 * sin_lam)**2 + ((cos_u1 * sin_u2) - (sin_u1 * cos_u2 * cos_lam))**2)
      return VincentySolution.new(distance: 0.0) if sin_sigma.zero? # co-incident points

      cos_sigma = (sin_u1 * sin_u2) + (cos_u1 * cos_u2 * cos_lam)
      sigma = Math.atan2(sin_sigma, cos_sigma)

      sin_alpha = cos_u1 * cos_u2 * sin_lam / sin_sigma
      cos_sq_alpha = 1 - sin_alpha**2

      cos_2sigma_m = cos_sq_alpha.zero? ? 0.0 : cos_sigma - 2.0 * sin_u1 * sin_u2 / cos_sq_alpha

      c = WGS84_F / 16.0 * cos_sq_alpha * (4.0 + WGS84_F * (4.0 - 3.0 * cos_sq_alpha))
      lam_prime = lam
      lam = delta_lambda + (1 - c) * WGS84_F * sin_alpha *
                           (sigma + c * sin_sigma * (cos_2sigma_m + c * cos_sigma * (-1 + 2 * cos_2sigma_m**2)))

      # Check if we need to iterate the solution as not yet close enough. Otherwise drop through to what is really
      # the loops exit condition.
      next if (lam - lam_prime).abs > 1e-12

      u_sq = cos_sq_alpha * (WGS84_A**2 - WGS84_B**2) / (WGS84_B**2)
      big_a = 1.0 + u_sq / 16_384 * (4096.0 + u_sq * (-768.0 + u_sq * (320.0 - 175.0 * u_sq)))
      big_b = (u_sq.to_f / 1024.0) * (256.0 + u_sq * (-128.0 + u_sq * (74.0 - 47.0 * u_sq)))
      delta_sigma = big_b * sin_sigma * (cos_2sigma_m + big_b / 4 * (cos_sigma * (-1.0 + 2.0 * (cos_2sigma_m**2.0)) -
        big_b / 6.0 * cos_2sigma_m * (-3.0 + 4.0 * (sin_sigma**2)) * (-3.0 + 4.0 * (cos_sigma**2))))

      distance = (WGS84_B * big_a * (sigma - delta_sigma)).round(3) / 1000.0 # 1mm precision expressed in km
      fwd_az = Math.atan2(cos_u2 * sin_lam, (cos_u1 * sin_u2) - (sin_u1 * cos_u2 * cos_lam))
      rev_az = Math.atan2(cos_u1 * sin_lam, (cos_u1 * sin_u2 * cos_lam) - (sin_u1 * cos_u2))

      return VincentySolution.new(distance: distance, initial_bearing: to_degrees(fwd_az), final_bearing: to_degrees(rev_az))
    end

    raise FailedToConvergeError
  end
  # rubocop: enable Metrics/MethodLength
  # rubocop: enable Metrics/AbcSize
end

class FailedToConvergeError < StandardError; end
