module Somadic
  module Channel
    class DI < Somadic::BaseChannel
      def initialize(channel, premium_id = nil)
        url = if premium_id
                "http://listen.di.fm/premium_high/#{channel}.pls?#{premium_id}"
              else
                "http://listen.di.fm/public3/#{channel}.pls"
              end
        # TODO: cache, cache_min
        options = { url: url }
        Somadic::Logger.debug("DI#initialize: options=#{options}")

        super(options)
      end
    end
  end
end
