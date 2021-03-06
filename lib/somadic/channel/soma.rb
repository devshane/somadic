# A wrapper around a soma.fm channel.
module Somadic
  module Channel
    class Soma < Somadic::BaseChannel
      def initialize(options)
        @options = options
        @channels = load_channels
        super(options.merge({ url: "http://somafm.com/#{options[:channel]}.pls" }))
      end

      # Overrides BaseChannel
      def find_channel(name)
        Somadic::Logger.debug("Soma#find_channel(#{name})")
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
        APICache.logger = Somadic::Logger
        APICache.get('soma_fm_chanel_list', cache: ONE_DAY, timeout: API_TIMEOUT) do
          Somadic::Logger.debug('Soma#load_channels')
          channels = []
          page = open('http://somafm.com/listen').read
          chans = page.scan(/href="http:\/\/somafm.com\/(.*?)\.pls/).flatten
          chans.each do |c|
            unless c.start_with?('fw/') || c.gsub(/\d+$/, '') != c
              channels << {id: 0, name: c, display_name: c}
            end
          end
          channels.sort_by! {|k, _| k[:name]}
          channels.uniq! {|k, _| k[:name]}

          channels
        end
      end

      def refresh_playlist
        # soma
        c = @options[:channel].gsub(/(130|64|48|32)$/, '')
        url = "http://somafm.com/#{c}/songhistory.html"

        f = open(url)
        page = f.read
        page.gsub!("\n", "")

        playlist = page.scan(/<!-- line \d+ -->.*?<tr>.*?<td>(.*?)<\/td>.*?<td>(<a.*?)<\/td>.*?<td>(.*?)<\/td>.*?<td>(.*?)<\/td>/)
        songs = []
        @next_load = Time.at(1)
        playlist.each do |song|
          if @next_load == Time.at(1)
            @next_load = Time.now + 30
          end
          next if song[3].scan(/<a.*?>(.*?)<\/a>/).empty?

          d = {}
          song[0] = song[0][0..song[0].index('&')-1] if song[0]['&'] # clean hh:mm:ss&nbsp; (Now)

          # TODO: ugh
          pt = Time.parse(song[0])
          local = Chronic.parse(pt.to_s.gsub(/-\d+$/, '-0800'))
          d[:started] = local.to_i

          d[:votes] = {up: 0, down: 0}
          d[:duration] = 0
          d[:artist] = strip_a(song[1])
          d[:title] = song[2]
          d[:track] = "#{d[:artist]} - #{d[:title]}"
          album = strip_a(song[3])
          d[:title] += "- #{strip_a(song[3])}" unless album.empty?
          songs << d
        end
        songs
      end

      # Removes anchor tags from `s`.
      def strip_a(s)
        results = s.scan(/<a.*?>(.*?)<\/a>/)
        return [] if results.empty?
        results[0][0]
      end
    end
  end
end
