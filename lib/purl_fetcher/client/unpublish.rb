# frozen_string_literal: true

module PurlFetcher
  class Client
    # Delete an item from the purl-fetcher cache
    class Unpublish
      # @param [String] druid the identifier of the item
      def self.unpublish(druid:)
        new(druid:).unpublish
      end

      # @param [String] druid the identifier of the item
      def initialize(druid:)
        @druid = druid
      end

      def unpublish
        logger.debug("Starting a unpublish request for: #{druid}")
        response = client.delete(path:)
        logger.debug("Unpublish request complete")
      end

      private

      attr_reader :druid

      def logger
        Client.config.logger
      end

      def client
        Client.instance
      end

      def path
        "/purls/#{druid}"
      end
    end
  end
end
