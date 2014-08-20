require 'spec_helper'

describe Somadic::Logger do
  it 'can log things' do
    Somadic::Logger.debug('test debug')
    Somadic::Logger.info('test info')
    Somadic::Logger.error('test info')
  end
end
