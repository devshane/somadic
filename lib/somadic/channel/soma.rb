module Somadic
  module Channel
    class Soma < Somadic::BaseChannel
      def initialize(channel)
        options = { url: "http://somafm.com/#{channel}.pls" }

        super(options)
        Somadic::Logger.debug("Soma#initialize: options=#{options}")
      end
    end
  end
end
