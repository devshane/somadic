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

      symbolized_data = []
      data.each { |d| symbolized_data << symbolize_keys(d) }
      @songs = symbolized_data.keep_if { |d| d[:title] }
    end

    private

    def symbolize_keys(hash)
      sym_hash = {}
      hash.each { |k, v| sym_hash[k.to_sym] = v.is_a?(Hash) ? symbolize_keys(v) : v }
      sym_hash
    end
  end
end
