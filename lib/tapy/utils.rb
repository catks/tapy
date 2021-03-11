module Tapy
  module Utils
    module PublishHelper
      private

      def publish(*events, **options)
        events.each do |event|
          Tapy.events.publish(event, **options)
        end
      end
    end
  end
end
