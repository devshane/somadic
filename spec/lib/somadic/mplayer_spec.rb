require 'spec_helper'

describe Somadic::Mplayer do
  it 'can start and stop mplayer' do
    mp = Somadic::Mplayer.new({ url: 'http://listen.di.fm/public3/breaks.pls' })
    expect(mp.cache).to be nil
    expect(mp.cache_min).to be nil
    if pidlist.empty?
      mp.start
      sleep secs_to_wait # let it spin up
      expect(pidlist.count).to be > 0

      mp.stop
      sleep secs_to_wait / 2 # let it die
      expect(pidlist.empty?).to be true
    else
      puts "\n!!! mplayer is already running, skipping test."
    end
  end

  it 'sets cache options correctly' do
    mp = Somadic::Mplayer.new({ url: 'http://ghost.com', cache: 999, cache_min: 90 })
    expect(mp.cache).to eql 999
    expect(mp.cache_min).to eql 90
  end
end
