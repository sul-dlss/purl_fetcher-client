# frozen_string_literal: true

module PurlFetcher
  class Client
    # Withdraw / restore a version of an item from the purl-fetcher cache
    class Withdraw
      # @param [String] druid the identifier of the item
      # @param [String] version the version of the item
      def self.withdraw(druid:, version:)
        new(druid:, version:).withdraw
      end

      # @param [String] druid the identifier of the item
      # @param [String] version the version of the item
      def self.restore(druid:, version:)
        new(druid:, version:).restore
      end

      # @param [String] druid the identifier of the item
      # @param [String] version the version of the item
      def initialize(druid:, version:)
        @druid = druid
        @version = version
      end

      def withdraw
        logger.debug("Starting a withdraw request for: #{druid} (#{version})")
        response = client.put(path: path(:withdraw))
        logger.debug("Withdraw request complete")
        response
      end

      def restore
        logger.debug("Starting a restore request for: #{druid} (#{version})")
        response = client.put(path: path(:restore))
        logger.debug("Withdraw request complete")
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

      def path(action)
        "/v1/purls/#{druid}/versions/#{version}/#{action}"
      end
    end
  end
end
