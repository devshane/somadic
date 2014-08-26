module Somadic
  class BaseChannel
    attr_reader :channels, :song

    API_TIMEOUT = 60
    ONE_DAY = 86400

    def initialize(options)
      @url = options[:url]
      playlist = @url.split('/').last
      @channel = find_channel(playlist[0..playlist.index('.pls') - 1])

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
  end
end
