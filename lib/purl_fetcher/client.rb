require "active_support"
require "active_support/core_ext"
require "faraday"
require "singleton"
require "logger"

require "purl_fetcher/client/version"
require "purl_fetcher/client/reader"
require "purl_fetcher/client/mods"
require "purl_fetcher/client/upload_files"
require "purl_fetcher/client/direct_upload_request"
require "purl_fetcher/client/direct_upload_response"
require "purl_fetcher/client/legacy_publish"
require "purl_fetcher/client/release_tags"
require "purl_fetcher/client/unpublish"

module PurlFetcher
  class Client
    # General error originating in PurlFetcher::Client
    class Error < StandardError; end

    # Raised when the response from the server is not successful
    class ResponseError < Error; end

    include Singleton
    class << self
      def configure(url:, logger: default_logger, token: nil)
        instance.config = Config.new(
          url: url,
          logger: logger,
          token: token
        )

        instance
      end

      def default_logger
        Logger.new($stdout)
      end

      delegate :config, to: :instance
    end

    attr_accessor :config

    # Send an DELETE request
    # @param path [String] the path for the API request
    def delete(path:)
      response = connection.delete(path)

      raise "unexpected response: #{response.status} #{response.body}" unless response.success?

      response.body
    end

    # Send an POST request
    # @param path [String] the path for the API request
    # @param body [String] the body of the POST request
    def post(path:, body:)
      response = connection.post(path) do |request|
        request.body = body
      end

      raise "unexpected response: #{response.status} #{response.body}" unless response.success?

      response.body
    end

    # Send an PUT request
    # @param path [String] the path for the API request
    # @param body [String] the body of the POST request
    # @param headers [Hash] extra headers to add to the SDR API request
    def put(path:, body:, headers: {})
      response = connection.put(path) do |request|
        request.body = body
        request.headers = default_headers.merge(headers)
      end

      raise "unexpected response: #{response.status} #{response.body}" unless response.success?

      response.body
    end

    private

    Config = Data.define(:url, :logger, :token)

    def connection
      Faraday.new(
        url: config.url,
        headers: default_headers,
        request: default_request_options
      ) do |conn|
        conn.response :json
      end
    end

    def default_headers
      {
        accept: "application/json",
        content_type: "application/json",
        authorization: auth_header
      }.compact
    end

    def default_request_options
      # To allow transfer of large files.
      {
          read_timeout: 900,
          timeout: 900
        }
    end

    def auth_header
      "Bearer #{config.token}" if config.token
    end
  end
end
