require_relative './api_helper'

r = 'usage: ruby invoke_function.rb <compartment-name> <app-name> ' \
    '<function-name> <request-payload-path>'
begin
  if ARGV.length == 4
    r = invoke_function(
      compartment_name: ARGV[0],
      app_name: ARGV[1],
      function_name: ARGV[2],
      payload: File.open(ARGV[3], 'rb').read
    ).data
  end
  puts r
rescue StandardError => e
  puts e.backtrace if ENV['DEBUG']
  puts "An error occurred: #{e.message}"
end
