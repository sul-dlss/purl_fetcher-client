require 'spec_helper'

RSpec.describe PurlFetcher::Client::Reader do
  subject(:reader) { described_class.new(settings) }
  let(:settings) { { 'purl_fetcher.target' => 'Searchworks' } }

  describe '#collection_members' do
    before do
      expect(HTTP).to receive(:get).with(%r{/collections/druid:xyz/purls}, params: hash_including(page: 1)).and_return(response)
    end

    let(:response) {
      instance_double(HTTP::Response, body: body, status: instance_double(HTTP::Response::Status, success?: true))
    }

    let(:body) do
      {
        purls: [
          { druid: 'x', true_targets: ['Searchworks'] },
          { druid: 'y', true_targets: ['Searchworks'] },
          { druid: 'z', true_targets: ['SomethingElse'] }
        ],
        pages: {}
      }.to_json
    end

    it 'returns collection members' do
      expect(reader.collection_members('xyz').map { |x| x.druid }).to eq %w[x y z]
    end
  end
end
