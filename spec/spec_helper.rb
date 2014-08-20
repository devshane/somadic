require 'somadic'

# How many seconds to wait for things to happen.
def secs_to_wait
  7
end

# Generates a list of mplayer PIDs.
def pidlist
  processes = `ps -C mplayer -o pid,cmd | grep -v defunct`.split("\n")[1..-1]
  processes.map { |p| p.split[0].to_i }
end

RSpec.configure do |config|
  config.before(:suite) do
    puts "!!!"
    puts "!!! These tests should play music!"
    puts "!!!"
  end
end
