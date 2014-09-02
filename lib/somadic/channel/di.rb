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
        @channels.each do |c|
          return c if c[:name] == name
        end
        nil
      end

      # Observer callback.
      #
      # TODO: time isn't used, song isn't required
      def update(time, song)
        Somadic::Logger.debug('DI#update')
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
        Somadic::Logger.debug('poll_for_song')
        aa = Somadic::AudioAddict.new(@channel[:id])
        songs = aa.refresh_playlist
        attempts = 0
        while songs.first[:track] != @song
          Somadic::Logger.debug("DI#poll_for_song[##{attempts}]: #{songs.first[:track]} != #{@song}")

          break if attempts > 5

          sleep attempts > 2 ? 5 : 2
          songs = aa.refresh_playlist
          attempts += 1
        end
        songs
      end

      # Loads the channel list.
      def load_channels
        APICache.logger = Somadic::Logger
        APICache.get('di_fm_channel_list', cache: ONE_DAY, timeout: API_TIMEOUT) do
          Somadic::Logger.debug('DI#load_channels')
          channels = []
          f = open('http://www.di.fm')
          page = f.read
          chan_ids = page.scan(/data-channel-id="(\d+)"/).flatten
          chans = page.scan(/data-tunein-url="http:\/\/www.di.fm\/(.*?)"/).flatten
          zipped = chan_ids.zip(chans)
          zipped.each do |z|
            channels << {id: z[0], name: z[1]}
          end
          channels.sort_by! {|k, _| k[:name]}
          channels.uniq! {|k, _| k[:name]}
        end
      end
    end
  end
end
