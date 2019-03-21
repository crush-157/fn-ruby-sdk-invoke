require_relative "./api_helper"

r = "usage: ruby invoke_function.rb <compartment-name> <app-name> " \
    "<function-name> [<request-payload>]"
begin
  case ARGV.length
  when 4
    r = invoke_function(compartment_name: ARGV[0], app_name: ARGV[1], function_name: ARGV[2], payload: ARGV[3]).data
  when 3
    puts "Invocation with no payload"
    r = invoke_function(compartment_name: ARGV[0], app_name: ARGV[1], function_name: ARGV[2]).data
  end
  puts r
rescue => e
  puts "An error occurred: #{e.message}"
end
