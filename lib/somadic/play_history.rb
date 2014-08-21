module Somadic
  class PlayHistory
    LOG_PATH = "#{ENV['HOME']}/.somadic/"
    LOG_FILE = 'play_history.log'

    def self.write(msg)
      instance.info(msg)
    end

    def self.instance
      FileUtils.mkdir_p(LOG_PATH) unless File.directory?(LOG_PATH)
      l = MonoLogger.new(File.join(LOG_PATH, LOG_FILE), 'daily')
      l.formatter = proc do |_, _, _, msg|
        "#{msg}\n"
      end
      l
    end
  end
end
