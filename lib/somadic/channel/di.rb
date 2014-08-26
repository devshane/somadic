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

        start_refresh_thread
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
      def update(time, song)
        @song = song if song
        aa = Somadic::AudioAddict.new(@channel[:id])
        songs = aa.refresh_playlist
        # if the current song is not in the playlist, create an entry for it
        # so the track name updates.
        if songs.first[:track] != @song
          songs.insert(0, { started: songs.first[:started],
                            duration: -1,
                            track: @song,
                            votes: { up: 0, down: 0 } })
        end
        @listeners.each do |l|
          l.update(@channel, songs) if l.respond_to?(:update)
        end
      end

      # Overrides BaseChannel.
      def stop
        Somadic::Logger.debug('DI#stop')
        @mp.stop
        @refresh_thread.exit
      end

      private

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

      def start_refresh_thread
        @refresh_thread = Thread.new do
          loop do
            update(Time.now, nil)
            sleep 10
          end
        end
      end
    end
  end
end
