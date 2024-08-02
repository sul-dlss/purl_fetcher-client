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
      # @param [String] version the version of the item
      # @param [DateTime] version_date the version date
      # @param [Boolean] must_version whether the item must be versioned
      def initialize(cocina:, file_uploads:, version:, version_date:, must_version:)
        @cocina = cocina
        @file_uploads = file_uploads
        @version = version
        @version_date = version_date
        @must_version = must_version
      end

      def publish
        logger.debug("Starting a publish request for: #{druid}")
        client.put(path:, body:)
        logger.debug("Publish request complete")
      end

      private

      attr_reader :cocina, :file_uploads, :version, :version_date, :must_version

      def druid
        cocina.externalIdentifier
      end

      def body
        {
          object: cocina.to_h,
          file_uploads: file_uploads,
          version: version,
          version_date: version_date.iso8601,
          must_version: must_version
      }.to_json
      end

      def logger
        Client.config.logger
      end

      def client
        Client.instance
      end

      def path
        "/v1/purls/#{druid}"
      end
    end
  end
end
