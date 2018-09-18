require "purl_fetcher/client/version"
require 'http'
begin
  require 'manticore' if defined? JRUBY_VERSION
rescue LoadError
end

module PurlFetcher
  module Client
    require 'purl_fetcher/client/public_xml_record'
    require 'purl_fetcher/client/reader'
    require 'purl_fetcher/client/deletes_reader'
    # Your code goes here...
  end
end
