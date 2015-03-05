# A wrapper around a DI.fm channel.
#
# Channel filters (not currently used, analogous to presets):
#
#    "channel_filters": [
#        {
#            "channels": [
#                348,
#                346,
#                291,
#                347
#            ],
#            "display": true,
#            "id": 20,
#            "key": "new",
#            "meta": false,
#            "name": "New",
#            "network_id": 1,
#            "position": 1,
#            "sprite": "//api.audioaddict.com/v1/assets/channel_sprite/di/new{/digest}{.format}{?width,height,quality}"
#        },
#        {
#            "channels": [
#                1,
#                2,
#                175,
#                7,
#                8,
#                346,
#                90,
#                125,
#                178,
#                176,
#                10
#            ],
#            "display": true,
#            "id": 5,
#            "key": "trance",
#            "meta": false,
#            "name": "Trance",
#            "network_id": 1,
#            "position": 2,
#            "sprite": "//api.audioaddict.com/v1/assets/channel_sprite/di/trance{/digest}{.format}{?width,height,quality}"
#        },
#        ...
#
# Each channel:
#
#    "channels": [
#        {
#            "ad_channels": "",
#            "asset_id": 54679,
#            "asset_url": "//static.audioaddict.com/e/4/b/3/4/6/e4b346b193c1adec01f8489b98a2bf3f.png",
#            "banner_url": null,
#            "channel_director": "takito jockey",
#            "created_at": "2014-12-02T10:03:54-05:00",
#            "description": "An emphasis on the bass and drums, delayed effects, sampled vocals and smokey Reggae inspired vibes.",
#            "description_long": "",
#            "description_short": "An emphasis on the bass and drums, delayed effects, sampled vocals and smokey Reggae inspired vibes.",
#            "favorite": false,
#            "forum_id": null,
#            "id": 348,
#            "images": {
#                "default": "//api.audioaddict.com/v1/assets/image/e4b346b193c1adec01f8489b98a2bf3f.png{?size,height,width,quality}"
#            },
#            "key": "dub",
#            "name": "Dub",
#            "network_id": 1,
#            "old_id": 729,
#            "premium_id": null,
#            "similar_channels": [
#                {
#                    "id": 666,
#                    "similar_channel_id": 91
#                },
#                {
#                    "id": 667,
#                    "similar_channel_id": 13
#                },
#                {
#                    "id": 668,
#                    "similar_channel_id": 15
#                }
#            ],
#            "tracklist_server_id": 25235,
#            "tunein_url": "http://www.di.fm/dub",
#            "updated_at": "2015-02-17T13:04:14-05:00"
#        },
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
          json['channels'].each do |c|
            channels << {id: c['id'], name: c['key'], display_name: c['name']}
          end

          channels
        end
      end
    end
  end
end
