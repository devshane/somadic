require 'logger'
require 'observer'

module Somadic
  # Your code goes here...
end

Dir[File.join(__dir__, 'somadic', '*.rb')].each { |f| require f }
Dir[File.join(__dir__, 'somadic', 'channel', '*.rb')].each { |f| require f }
