require 'spec_helper'

describe Somadic::Mplayer do
  def pidlist
    processes = `ps -C mplayer -o pid,cmd | grep -v defunct`.split("\n")[1..-1]
    processes.map { |p| p.split[0].to_i }
  end

  it 'sets cache options correctly' do
    mp = Somadic::Mplayer.new('http://ghost.com', cache: 999, cache_min: 90)
    expect(mp.cache).to eql 999
    expect(mp.cache_min).to eql 90
  end

  it 'can start and stop mplayer' do
    mp = Somadic::Mplayer.new('http://listen.di.fm/public3/breaks.pls')
    expect(mp.cache).to be > 0
    expect(mp.cache_min).to be > 0
    if pidlist.empty?
      mp.start
      sleep 5 # let it spin up
      expect(pidlist.count).to be > 0

      mp.stop
      sleep 5 # let it die
      expect(pidlist.empty?).to be true
    else
      puts "\n!!!"
      puts "!!! mplayer is already running, skipping test."
      puts "!!!"
    end
  end
end
