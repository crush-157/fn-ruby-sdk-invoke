require_relative './api_helper'

r = 'usage: ruby invoke_function.rb <compartment-name> <app-name> ' \
    '<function-name> [<request-payload>]'
begin
  if ARGV.length.between?(3, 4)
    r = invoke_function(
      compartment_name: ARGV[0],
      app_name: ARGV[1],
      function_name: ARGV[2],
      payload: ARGV.fetch(3, '')
    ).data
  end
  puts r
rescue StandardError => e
  puts e.backtrace if ENV['DEBUG']
  puts "An error occurred: #{e.message}"
end
