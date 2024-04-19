require "purl_fetcher/client/version"
require 'http'

module PurlFetcher
  module Client
    require 'purl_fetcher/client/public_xml_record'
    require 'purl_fetcher/client/reader'
    
    # General error originating in PurlFetcher::Client
    class Error < StandardError; end

    # Raised when the response from the server is not successful
    class ResponseError < Error; end
  end
end
