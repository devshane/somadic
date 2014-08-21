module Somadic
  module Channel
    class DI < Somadic::BaseChannel
      def initialize(options)
        url = if options[:premium_id]
          "http://listen.di.fm/premium_high/#{options[:channel]}.pls?#{options[:premium_id]}"
        else
          "http://listen.di.fm/public3/#{options[:channel]}.pls"
        end
        super(options.merge({ url: url }))
        Somadic::Logger.debug("DI#initialize: options=#{options}")
      end
    end
  end
end
