require 'spec_helper'

RSpec.describe PurlFetcher::Client::Reader do
  subject(:reader) { described_class.new }

  describe '#collection_members' do
    before do
      stub_request(:get, "https://purl-fetcher.stanford.edu/collections/druid:xyz/purls?params%5Bpage%5D=1&params%5Bper_page%5D=1000").
        to_return(status: 200, body:, headers: { 'content-type' => 'application/json' })
    end

    let(:body) do
      {
        purls: [
          { druid: 'x', true_targets: [ 'Searchworks' ] },
          { druid: 'y', true_targets: [ 'Searchworks' ] },
          { druid: 'z', true_targets: [ 'SomethingElse' ] }
        ],
        pages: {}
      }.to_json
    end

    it 'returns collection members' do
      expect(reader.collection_members('xyz').to_a).to eq %w[x y z]
    end
  end
end
