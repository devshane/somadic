module Somadic
  class BaseChannel
    attr_reader :channels, :song

    API_TIMEOUT = 60
    ONE_DAY = 86400

    def initialize(options)
      @url = options[:url]
      playlist = @url.split('/').last
      if playlist.end_with?('.pls')
        name = playlist[0..playlist.index('.pls') - 1]
      elsif playlist.end_with?('.m3u')
        name = playlist[0..playlist.index('.m3u') - 1]
      else
        Somadic::Logger.error("BaseChannel#initialize: bad playlist #{playlist}")
        return
      end
      @channel = find_channel(name)

      @mp = Mplayer.new(options)
      @mp.add_observer(self)
      @listeners = options[:listeners]
    end

    # Let's go already.
    def start
      Somadic::Logger.debug('BaseChannel#start')
      @mp.start
    rescue => e
      Somadic::Logger.error("BaseChannel#start error: #{e}")
    end

    # Enough already.
    def stop
      Somadic::Logger.debug('BaseChannel#stop')
      @mp.stop
    end

    def stopped?
      @mp.stopped?
    end

    # Observer callback, and also one of the simplest displays possible.
    def update(time, song)
      Somadic::Logger.debug("BaseChannel#update: #{time} - #{song}")
      songs = [{ 'started' => Time.now.to_i - 1,
                 'duration' => 1,
                 'track' => song,
                 'votes' => { 'up' => 0, 'down' => 0 } }]
      @listeners.each do |l|
        l.update(@channel, songs) if l.respond_to?(:update)
      end
    end

    def find_channel(name)
      raise NotImplementedError
    end

    def channel_list
      @channels
    end
  end
end
