require 'fileutils'

module Somadic
  class Logger
    LOG_PATH = "#{ENV['HOME']}/.somadic/"
    LOG_FILE = 'somadic.log'

    def self.debug(msg)
      instance.debug(msg)
    end

    def self.info(msg)
      instance.info(msg)
    end

    def self.error(msg)
      instance.error(msg)
    end

    def self.warn(msg)
      instance.warn(msg)
    end

    def self.instance
      ::FileUtils.mkdir_p(LOG_PATH) unless File.directory?(LOG_PATH)
      l = MonoLogger.new(File.join(LOG_PATH, LOG_FILE), 'daily')
      l.formatter = proc do |severity, datetime, _, msg|
        "[#{severity}] #{datetime}: #{msg}\n"
      end
      l
    end
  end
end
