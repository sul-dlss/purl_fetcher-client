# frozen_string_literal: true

module PurlFetcher
  class Client
    # Transfer release tags to purl-fetcher
    class ReleaseTags
      # @param [String] druid the identifier of the object
      # @param [Array<String>] index ([]) list of properties to index to
      # @param [Array<String>] delete ([]) list of properties to delete from
      def self.release(druid:, index: [], delete: [])
        new(druid:, index:, delete:).release
      end

      # @param [String] druid the identifier of the object
      # @param [Array<String>] index ([]) list of properties to index to
      # @param [Array<String>] delete ([]) list of properties to delete from
      def initialize(druid:, index: [], delete: [])
        @druid = druid
        @index = index
        @delete = delete
      end

      def release
        logger.debug("Starting an release request for: #{druid}")
        response = client.put(path:, body:)
        logger.debug("Release request complete")
      end

      private

      attr_reader :druid, :index, :delete

      def body
        { index:, delete: }.to_json
      end

      def logger
        Client.config.logger
      end

      def client
        Client.instance
      end

      def path
        "/v1/released/#{druid}"
      end
    end
  end
end
