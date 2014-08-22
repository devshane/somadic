require 'spec_helper'

describe Somadic::AudioAddict do
  it 'can refresh a playlist' do
    aa = Somadic::AudioAddict.new(4)
    songs = aa.refresh_playlist
    expect(songs.count).to be > 0
    s = songs.first
    expect(s['title'].length).to be > 0
    expect(s['votes'].length).to eql 4
  end
end
