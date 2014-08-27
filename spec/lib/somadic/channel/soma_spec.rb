require 'spec_helper'

describe Somadic::Channel::Soma do
  it 'can play Soma' do
    if pidlist.empty?
      soma = Somadic::Channel::Soma.new({ channel: 'secretagent130' })
      soma.start
      sleep secs_to_wait # let it spin up
      expect(pidlist.count).to be > 0

      soma.stop
      sleep secs_to_wait / 2 # let it die
      expect(pidlist.empty?).to be true
    else
      puts "\n!!! mplayer is already running, skipping Soma test."
    end
  end

  it 'blows up with a bad channel'

  it 'can get a channel list' do
    soma = Somadic::Channel::Soma.new({ channel: 'secretagent130' })
    expect(soma.channels.count).to be > 0
    expect(soma.channels.include?({ id: 0, name: 'secretagent' })).to be true
    expect(soma.channels.include?({ id: 0, name: 'groovesalad' })).to be true
  end
end
