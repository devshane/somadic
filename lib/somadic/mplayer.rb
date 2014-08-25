module Somadic
  class Mplayer
    include Observable

    MPLAYER = 'mplayer'

    attr_accessor :url, :cache, :cache_min

    # Sets up a new instance of Mplayer.
    #
    # Valid options are:
    #
    #   :cache     - how much memory in kBytes to use when precaching
    #                a file or URL
    #   :cache_min - playback will start when the cache has been filled up
    #                to `cache_min` of the total.
    #
    # See the mplayer man page for more.
    def initialize(options)
      @url = options[:url]
      @cache = options[:cache]
      @cache_min =options[:cache_min]
    end

    # Starts mplayer on a new thread.
    def start
      @player_thread = Thread.new do
        cmd = command
        Somadic::Logger.debug("Mplayer#start: popen #{cmd}")
        pipe = IO.popen(cmd, 'r+')
        loop do
          line = pipe.readline.chomp
          if line['Starting playback']
            Somadic::Logger.debug("Mplayer#pipe: #{line}")
          elsif line['ICY']
            Somadic::Logger.debug("Mplayer#pipe: #{line}")
            _, v = line.split(';')[0].split('=')
            song = v[1..-2]
            notify(song)
          end
        end
        pipe.close
      end
    end

    # Stops mplayer.
    def stop
      Somadic::Logger.debug("Mplayer#stop")
      `killall mplayer`
    end

    private

    # Builds the command line for launching mplayer.
    def command
      cmd = MPLAYER
      cmd = "#{cmd} -cache #{@cache}" if @cache
      cmd = "#{cmd} -cache-min #{@cache_min}" if @cache_min
      cmd = "#{cmd} -playlist #{@url}"
      cmd = "#{cmd} 2>&1"
      cmd
    end

    # Tell everybody who cares that something happened.
    def notify(message)
      Somadic::Logger.debug("Mplayer#notify(#{message})")
      changed
      notify_observers(Time.now, message)
    end
  end
end
