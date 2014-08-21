module Somadic
  module Channel
    class Soma < Somadic::BaseChannel
      def initialize(options)
        super(options.merge({ url: "http://somafm.com/#{channel}.pls" }))
        Somadic::Logger.debug("Soma#initialize: options=#{options}")
      end
    end
  end
end
