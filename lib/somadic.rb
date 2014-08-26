require 'mono_logger'
require 'observer'
require 'open-uri'
require 'json'
require 'api_cache'

module Somadic
  # Your code goes here...
end

Dir[File.join(__dir__, 'somadic', '*.rb')].each { |f| require f }
Dir[File.join(__dir__, 'somadic', 'channel', '*.rb')].each { |f| require f }
