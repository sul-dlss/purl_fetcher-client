class PurlFetcher::Client::Reader
  include Enumerable

  attr_reader :host, :conn, :range

  def initialize(host: "https://purl-fetcher.stanford.edu", conn: nil)
    @host = host
    @conn = conn || Faraday.new(host) do |f|
              f.response :json
            end
    @range = {}
  end

  # @return [Hash] a hash including member item's druid and release targets
  # @raise [PurlFetcher::Client::NotFoundResponseError] if item is not found
  # @raise [PurlFetcher::Client::ResponseError] if the response is not successful
  def collection_members(druid)
    return to_enum(:collection_members, druid) unless block_given?

    paginated_get("/collections/druid:#{druid.delete_prefix('druid:')}/purls", "purls").each { |member| yield member }
  end

  # @return [Hash] a hash including the item's druid and its last updated time
  def released_to(target)
    return to_enum(:released_to, ERB::Util.url_encode(target)) unless block_given?

    retrieve_json("/released/#{target}").each { |item| yield item }
  end

  # @return [Array<Hash<String,String>>] a list of hashes where the key is a digest and the value is a filepath/filename
  # @raise [PurlFetcher::Client::NotFoundResponseError] if item is not found
  # @raise [PurlFetcher::Client::ResponseError] if the response is not successful
  def files_by_digest(druid)
    retrieve_json("/v1/purls/druid:#{druid.delete_prefix('druid:')}", {})
      .fetch("files_by_md5", [])
  end

  private

  ##
  # @return [Hash] a parsed JSON hash
  def retrieve_json(path, params = {})
    response = conn.get(path, params)

    unless response.success?
      raise PurlFetcher::Client::NotFoundResponseError, "Item not found" if response.status == 404
      if defined?(Honeybadger)
        Honeybadger.context({ path:, params:, response_code: response.status, body: response.body })
      end
      raise PurlFetcher::Client::ResponseError, "Unsuccessful response from purl-fetcher"
    end

    response.body
  end

  ##
  # For performance, and enumberable object is returned.
  #
  # @example operating on each of the results as they come in
  #   paginated_get('/docs/collections/druid:123', 'purls').map { |v| puts v.inspect }
  #
  # @example getting all of the results and converting to an array
  #   paginated_get('/docs/collections/druid:123', 'purls').to_a
  #
  # @return [Enumerator] an enumberable object
  def paginated_get(path, accessor, options = {})
    Enumerator.new do |yielder|
      params   = options.dup
      per_page = params.delete(:per_page) { 1000 }
      page     = params.delete(:page) { 1 }
      max      = params.delete(:max) { 1_000_000 }
      total    = 0

      loop do
        data = retrieve_json(path, { per_page: per_page, page: page }.merge(params))
        @range = data["range"]

        total += data[accessor].length

        data[accessor].each do |element|
          yielder.yield element, self
        end

        page = data["pages"]["next_page"]

        break if page.nil? || total >= max
      end
    end
  end
end
