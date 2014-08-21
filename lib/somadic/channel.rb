module Somadic
  class BaseChannel
    def initialize(options)
      @url = options[:url]
      playlist = @url.split('/').last
      @channel = playlist[0..playlist.index('.pls') - 1]

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
      @listeners.each do |l|
        l.update(@channel, song) if l.respond_to?(:update)
      end
    end
  end
end
