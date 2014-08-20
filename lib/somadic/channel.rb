module Somadic
  class BaseChannel
    def initialize(options)
      @url = options[:url]
      @mp = Mplayer.new(@url)
      @mp.add_observer(self)
    end

    # Let's go already.
    def start
      # TODO: what about passing in cache, cache-min?
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
      puts "[#{channel}] #{time.strftime('%H:%M:%S')} #{song}"
    end

    def channel
      c = @url.split('/').last
      c[0..c.index('.pls') - 1]
    end
  end
end
