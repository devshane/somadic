require 'spec_helper'

describe Somadic::Channel::DI do
  it 'can play DI' do
    if pidlist.empty?
      di = Somadic::Channel::DI.new({ channel: 'breaks' })
      di.start
      sleep secs_to_wait # let it spin up
      expect(pidlist.count).to be > 0

      di.stop
      sleep secs_to_wait / 2 # let it die
      expect(pidlist.empty?).to be true
    else
      puts "\n!!! mplayer is already running, skipping DI test."
    end
  end

  it 'blows up with a bad channel'

  it 'can load a channel list' do
    di = Somadic::Channel::DI.new({ channel: 'breaks' })
    expect(di.channels.count).to be > 10
  end

  it 'can find a channel by name' do
    di = Somadic::Channel::DI.new({ channel: 'breaks' })
    c = di.find_channel('breaks')
    expect(c[:id].to_i).to eql 15
  end
end
