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
    def initialize(url, options = {})
      @url = url
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
          Somadic::Logger.debug("Mplayer#pipe: #{line}")
          if line['Starting playback']
            # playing...
          elsif line['ICY']
            parts = line.split(';')
            song = parts[0].match(/'(.*?)'/)[1]
            notify(song)
          end
        end
        pipe.close
      end
    end

    # Stops mplayer.
    def stop
      Somadic::Logger.debug("Mplayer#stop")
      pidlist.each do |pid|
        Somadic::Logger.debug("Mplayer#stop: sending SIGTERM to pid #{pid}")
        Process.kill :SIGTERM, pid
      end
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

    # Gets a list of mplayer PIDs.
    def pidlist
      `ps -C #{MPLAYER} -o pid`.split[1..-1].map! { |p| p.to_i }
    end

    # Tell everybody who cares that something happened.
    def notify(message)
      Somadic::Logger.debug("Mplayer#notify(#{message})")
      changed
      notify_observers(Time.now, message)
    end
  end
end
