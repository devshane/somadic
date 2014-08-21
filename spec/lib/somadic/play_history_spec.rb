require 'spec_helper'

describe Somadic::PlayHistory do
  it 'can log history' do
    Somadic::PlayHistory.write('Some bitchin song')
  end
end
