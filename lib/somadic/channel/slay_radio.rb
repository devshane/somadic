# A wrapper around a SLAYradio channel.
module Somadic
  module Channel
    class SlayRadio < Somadic::BaseChannel
      CHANNEL_NAME = 'slayradio'

      def initialize(options)
        @options = options
        @options[:channel] = CHANNEL_NAME
        @channels = load_channels
        super(options.merge({ url: 'http://www.slayradio.org/tune_in.php/128kbps/slayradio.128.m3u' }))
      end

      # Overrides BaseChannel
      def find_channel(name)
        Somadic::Logger.debug("SlayRadio#find_channel(#{name})")
        { id: 0, name: name, display_name: name }
      end

      # Observer callback.
      def update(time, song)
        @song = song if song
        songs = refresh_playlist
        channel = { id: 0, name: @options[:channel], display_name: @options[:channel] }
        @listeners.each do |l|
          l.update(channel, songs) if l.respond_to?(:update)
        end
      end

      private

      def load_channels
        [{id: 0, name: @options[:channel], display_name: @options[:channel]}]
      end

      def refresh_playlist
        url = 'https://www.slayradio.org/api.php?query=rotationalhistory'
        page = open(url).read
        json = JSON.parse(page)
        songs = []
        json['data'].each do |song|
          artist = song['artist']
          title = song['title']
          if artist == title
            track = artist
          else
            track = "#{artist} - #{title}"
          end
          songs << { started: Time.at(song['nowplaying'].to_i),
                     votes: {up: 0, down: 0},
                     duration: duration(song['duration'].to_i),
                     artist: artist,
                     title: title,
                     track: track }
        end
        songs
      rescue => e
        Somadic::Logger.error("SlayRadio#refresh_playlist: error #{e}")
      end

      def duration(val)
        Time.at(val/1000).to_i
      end
    end
  end
end
