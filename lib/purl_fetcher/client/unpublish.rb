# frozen_string_literal: true

module PurlFetcher
  class Client
    # Delete an item from the purl-fetcher cache
    class Unpublish
      # @param [String] druid the identifier of the item
      # @param [String] version the version of the item
      # @raise [Purl::Fetcher::Client::AlreadyDeletedResponseError] if the item is already deleted
      def self.unpublish(druid:, version:)
        new(druid:, version:).unpublish
      end

      # @param [String] druid the identifier of the item
      # @param [String] version the version of the item
      def initialize(druid:, version:)
        @druid = druid
        @version = version
      end

      def unpublish
        logger.debug("Starting a unpublish request for: #{druid} (#{version})")
        response = client.delete(path:, params: { version: version })
        logger.debug("Unpublish request complete")
        response
      end

      private

      attr_reader :druid, :version

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
