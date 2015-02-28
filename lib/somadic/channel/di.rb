require 'pp'

module Somadic
  module Channel
    class DI < Somadic::BaseChannel
      def initialize(options)
        url = if options[:premium_id]
          "http://listen.di.fm/premium_high/#{options[:channel]}.pls?#{options[:premium_id]}"
        else
          "http://listen.di.fm/public3/#{options[:channel]}.pls"
        end
        @channels = load_channels
        super(options.merge({ url: url }))
      end

      # Overrides BaseChannel
      def find_channel(name)
        Somadic::Logger.debug("DI#find_channel(#{name})")
        @channels.each { |c| return c if c[:name] == name }
        nil
      end

      # Observer callback.
      #
      # TODO: time isn't used, song isn't required
      def update(time, song)
        return unless @channel

        @song = song if song
        aa = Somadic::AudioAddict.new(@channel[:id])
        songs = aa.refresh_playlist
        if songs.first[:track] != @song
          # try again
          songs = poll_for_song
        end
        @listeners.each do |l|
          Somadic::Logger.debug("DI#update: updating listener #{l}")
          l.update(@channel, songs) if l.respond_to?(:update)
        end
      rescue => e
        Somadic::Logger.error("DI#update: error #{e}")
      end

      # Overrides BaseChannel.
      def stop
        Somadic::Logger.debug('DI#stop')
        @mp.stop
      end

      private

      def poll_for_song
        aa = Somadic::AudioAddict.new(@channel[:id])
        songs = aa.refresh_playlist
        one_minute_from_now = Time.now + 1
        while songs.first[:track] != @song
          Somadic::Logger.debug("DI#poll_for_song: #{songs.first[:track]} != #{@song}")
          break if Time.now > one_minute_from_now
          sleep one_minute_from_now - Time.now < 15 ? 2 : 5
          songs = aa.refresh_playlist
        end
        songs
      end

      # Loads the channel list.
      def load_channels
        APICache.logger = Somadic::Logger
        APICache.get('di_fm_channel_list', cache: ONE_DAY, timeout: API_TIMEOUT) do
          Somadic::Logger.debug('DI#load_channels')
          channels = []
          page = open('http://www.di.fm').read
          app_start = page.scan(/di\.app\.start\((.*?)\);/).flatten[0]
          json = JSON.parse(app_start)
          json['channels'].each { |c| channels << {id: c['id'], name: c['key']} }

          channels
        end
      end
    end
  end
end
