module Somadic
  class AudioAddict
    def initialize(channel_id)
      @url = "http://api.audioaddict.com/v1/di/track_history/channel/" \
             "#{channel_id}.jsonp?callback=_AudioAddict_TrackHistory_Channel"
    end

    def refresh_playlist
      f = open(@url)
      page = f.read
      data = JSON.parse(page[page.index("(") + 1..-3])
      @songs = data.keep_if { |d| d['title'] }
    end
  end
end
