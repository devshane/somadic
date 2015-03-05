# A curses display.
class Display
  include Curses

  attr_reader :channel
  attr_accessor :kp_queue, :stopped, :search_phrase, :inputting

  def initialize
    curses_init
    @bar = ProgressBar.new(1, :bar)

    @kp_queue = Queue.new
    start_keypress_thread
  end

  # Refreshes the display.
  def refresh
    Somadic::Logger.debug('Display#refresh')
    Curses.clear
    Curses.refresh
  end

  def search(channel)
    #cpos Curses.lines - 1, 0
    @inputting = true
    Curses.close_screen
    @search_phrase = Readline.readline('Go to channel: ', true)
    @search_phrase = '' unless @search_phrase[':']
    cwrite Curses.lines - 1, 0, ''
    @inputting = false
  end

  def clear_search
    cwrite Curses.lines - 1, 0, ''
  end

  # Updates the display.
  def update(channel = nil, songs = nil)
    @channel = channel if channel
    @songs = songs if songs
    return if @channel.nil? || @songs.nil?

    cur_song = @songs.first
    return if cur_song.nil?

    # times
    start_time = Time.at(cur_song[:started]) rescue Time.now
    duration = cur_song[:duration]
    if @stopped
      end_time = nil
      elapsed = (Time.now - start_time).to_i
      remains = '][ Paused ]'
    elsif duration <= 0
      end_time = nil
      elapsed = (Time.now - start_time).to_i
      remains = duration < 0 ?
                '][ Updating ]' :
                "][ #{format_secs(elapsed)} ]"
    else
      end_time = start_time + duration
      remains = "][ #{format_secs((Time.now - start_time).to_i)} " \
                "/ #{format_secs(duration)} ]"
    end

    # current song
    track = cur_song[:track]
    channel_and_track = "[ #{clean_channel_name(@channel[:display_name])} > #{track}"

    up = cur_song[:votes][:up]
    down = cur_song[:votes][:down]
    votes = up + down != 0 ? "+#{up}/-#{down}" : ''

    space_len = Curses.cols - votes.length - channel_and_track.length - remains.length - 1
    spaces = space_len > 0 ? ' ' * space_len : ' '

    line = "#{channel_and_track}#{spaces}#{votes} #{remains}"
    over = Curses.cols - line.length
    if over < 0
      channel_and_track = channel_and_track[0..over - 1]
      line = "#{channel_and_track}#{spaces}#{votes} #{remains}"
    end
    cwrite 0, 0, line, curses_reverse

    # current song progress
    unless @stopped
      if duration <= 0
        @bar.max = @bar.count = 100
      else
        @bar.max = duration
        @bar.count = (Time.now - start_time).to_i
      end
      cwrite 1, 0, @bar.to_s, curses_bold
    end

    # song history
    row = 2
    @songs[1..-1].each do |song|
      up = song[:votes][:up]
      down = song[:votes][:down]
      votes = up + down != 0 ? " +#{up}/-#{down} :" : ''

      if song[:duration] == 0
        duration = Time.at(song[:started]).strftime('%H:%M:%S')
      else
        duration = format_secs(song[:duration])
      end

      track = ": #{song[:track]}"
      votes_and_duration = "#{votes} #{duration} :"

      space_len = Curses.cols - track.length - votes_and_duration.length
      spaces = space_len > 0 ? ' ' * space_len : ''

      line = "#{track}#{spaces}#{votes_and_duration}"
      if space_len < 0
        spaces = ' '
        track = track[0..space_len - 2]
        line = "#{track}#{spaces}#{votes_and_duration}"
      end
      cwrite row, 0, line, curses_dim
      row += 1
    end

    while row < Curses.lines - 1
      clear_line row
      row += 1
    end

    # TODO: this works around the dupe thing @startup, but it shouldn't be
    # necessary
    cwrite row, 0, ''
    cpos Curses.lines - 1, 0
  end

  def show_channels(list)
    container = Curses::Window.new(0, 0, 0, 0)
    w = container.subwin(Curses.lines, Curses.cols, 0, 0)
    w.addstr("[ Channels ]\n\n")
    #w.setscrreg(0, Curses.lines)
    #w.scrollok(true)
    w.addstr("#{in_columns(list)}\n")
    w.addstr("Press q to close channel list.")
    w.getch
    w.close

    refresh
  end

  private

  # Breaks a channel list up into columns.
  def in_columns(list)
    longest = 0
    list.each { |l| longest = l[:name].length if l[:name].length > longest }
    chan_list = list.map do |l|
      ll = longest - l[:name].length
      pad = if ll > 0
              ' ' * ll
            else
              ''
            end
      "#{l[:name]}#{pad}"
    end.sort

    cols = Curses.cols / (longest + 1)
    groups = chan_list.each_slice(cols).to_a
    chans = ''
    groups.each { |g| chans << "#{g.join(' ')}\n" }

    chans
  end

  def start_keypress_thread
    Thread.new do
      loop do
        unless @inputting
          ch = Curses.getch
          @kp_queue << ch if ch
        end
        sleep 0.1
      end
    end
  end

  # Curses init
  def curses_init
    #Curses.noecho
    #Curses.curs_set(0)
    Curses.timeout = -1

    Curses.init_screen
    Curses.start_color

    Curses.init_pair(COLOR_WHITE, COLOR_WHITE, COLOR_BLACK)
  end

  # Curses write
  def cwrite(row, col, message, color = nil)
    Curses.setpos(row, col)
    Curses.clrtoeol

    if color
      Curses.attron(color) { Curses.addstr(message) }
    else
      Curses.addstr(message)
    end

    Curses.refresh
  end

  # Cursor pos
  def cpos(row, col)
    Curses.setpos(row, col)
    Curses.refresh
  end

  # Colors/styles.
  def curses_bold
    curses_white|A_BOLD
  end

  def curses_reverse
    curses_white|A_REVERSE
  end

  def curses_dim
    curses_white|A_DIM
  end

  def curses_white
    color_pair(COLOR_WHITE)
  end

  def clear_line(row)
    Curses.setpos(row, 0)
    Curses.clrtoeol
  end

  # Formats `seconds` to hours, mins, secs.
  def format_secs(seconds)
    secs = seconds.abs
    hours = 0
    if secs > 3600
      hours = secs / 3600
      secs -= 3600 * hours
    end
    mins = secs / 60
    secs = secs % 60
    h = hours > 0 ? "#{"%1d" % hours}:" : "  "
    "#{h}#{"%02d" % mins}:#{"%02d" % secs}"
  end

  # Cleans up soma channel names.
  def clean_channel_name(name)
    cname = name.gsub(/130$/, '')
    cname.gsub!(/64$/, '')
    cname
  end
end
