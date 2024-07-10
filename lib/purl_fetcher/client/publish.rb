# frozen_string_literal: true

module PurlFetcher
  class Client
    # Publish (metadata-only) to the purl cache
    class Publish
      def self.publish(...)
        new(...).publish
      end

      # @param [Cocina::Models::DRO,Cocina::Models::Collection] cocina the Cocina data object
      # @param [Hash<String,String>] file_uploads map of cocina filenames to staging filenames (UUIDs)
      def initialize(cocina:, file_uploads:)
        @cocina = cocina
        @file_uploads = file_uploads
      end

      def publish
        logger.debug("Starting a publish request for: #{druid}")
        client.post(path:, body:)
        logger.debug("Publish request complete")
      end

      private

      attr_reader :cocina, :file_uploads

      def druid
        cocina.externalIdentifier
      end

      def body
        {
          object: cocina.to_h,
          file_uploads: file_uploads
      }.to_json
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
