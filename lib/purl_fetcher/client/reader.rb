class PurlFetcher::Client::Reader
  include Enumerable
  attr_reader :settings, :range

  def initialize(settings = {})
    @settings = settings
    @range = {}
  end

  def collection_members(druid)
    return to_enum(:collection_members, druid) unless block_given?

    paginated_get("/collections/druid:#{druid.sub(/^druid:/, '')}/purls", 'purls').each do |obj, _meta|
      yield PurlFetcher::Client::PublicXmlRecord.new(obj['druid'].sub('druid:', ''), settings), obj, self
    end
  end

  private

  ##
  # @return [Hash] a parsed JSON hash
  def get(path, params = {})
    body = fetch(settings.fetch('purl_fetcher.api_endpoint', 'https://purl-fetcher.stanford.edu') + path, params)
    JSON.parse(body)
  end

  def fetch(url, params)
    response = if defined?(Manticore) # for JRuby
      Manticore.get(url, query: params) #response.code
    else
      HTTP.get(url, params: params)
    end

    unless response.code.between?(200, 299) # success. Manticore doesn't have response.status.
      if defined?(Honeybadger)
        Honeybadger.context({ url: url, params: params, response_code: response.code, body: response.body })
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
        data = get(path, { per_page: per_page, page: page }.merge(params))
        @range = data['range']

        total += data[accessor].length

        data[accessor].each do |element|
          yielder.yield element, self
        end

        page = data['pages']['next_page']

        break if page.nil? || total >= max
      end
    end
  end
end
