# frozen_string_literal: true

module PurlFetcher
  class Client
    # Publish (metadata-only) to the purl cache
    class Publish
      # @param [Cocina::Models::DRO,Cocina::Models::Collection] cocina the Cocina data object
      def self.publish(cocina:)
        new(cocina:).publish
      end

      # @param [Cocina::Models::DRO,Cocina::Models::Collection] cocina the Cocina data object
      def initialize(cocina:)
        @cocina = cocina
      end

      def publish
        logger.debug("Starting a publish request for: #{druid}")
        response = client.post(path:, body:)
        logger.debug("Publish request complete")
      end

      private

      attr_reader :cocina

      def druid
        cocina.externalIdentifier
      end

      def body
        cocina.to_json
      end

      def logger
        Client.config.logger
      end

      def client
        Client.instance
      end

      def path
        "/v1/resources"
      end
    end
  end
end
