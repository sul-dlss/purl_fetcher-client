require 'spec_helper'

RSpec.describe PurlFetcher::Client::Reader do
  subject(:reader) { described_class.new }

  describe '#collection_members' do
    before do
      stub_request(:get, "https://purl-fetcher.stanford.edu/collections/druid:xyz/purls?page=1&per_page=1000").
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
      expect(reader.collection_members('xyz').to_a).to eq [
        { 'druid' => 'x', 'true_targets' => [ 'Searchworks' ] },
        { 'druid' => 'y', 'true_targets' => [ 'Searchworks' ] },
        { 'druid' => 'z', 'true_targets' => [ 'SomethingElse' ] }
      ]
    end
  end

  describe '#released_to' do
    before do
      stub_request(:get, "https://purl-fetcher.stanford.edu/released/Searchworks").
        to_return(status: 200, body:, headers: { 'content-type' => 'application/json' })
    end

    let(:body) do
      [
        { druid: 'druid:abc123', last_updated: '2023-10-01T12:00:00Z' },
        { druid: 'druid:def456', last_updated: '2023-10-02T12:00:00Z' }
      ].to_json
    end

    it 'returns items released to the target' do
      expect(reader.released_to('Searchworks').to_a).to eq [
        { 'druid' => 'druid:abc123', 'last_updated' => '2023-10-01T12:00:00Z' },
        { 'druid' => 'druid:def456', 'last_updated' => '2023-10-02T12:00:00Z' }
      ]
    end
  end

  describe '#files_by_digest' do
    before do
      stub_request(:get, "https://purl-fetcher.stanford.edu/v1/purls/druid:xyz").
        to_return(status: 200, body: body.to_json, headers: { 'content-type' => 'application/json' })
    end

    let(:body) do
      {
        files_by_md5: [
          { "7142ce948827c16120cc9e19b05acd49" => "sul-logo.png" }
        ]
      }
    end

    it 'returns files indexed by their digests' do
      expect(reader.files_by_digest('xyz')).to eq([ { "7142ce948827c16120cc9e19b05acd49" => "sul-logo.png" } ])
    end

    context 'when there are no files' do
      let(:body) do
        { files_by_md5: [] }
      end

      it 'returns an empty array' do
        expect(reader.files_by_digest('xyz')).to eq([])
      end
    end

    context 'when the body is empty' do
      let(:body) { {} }

      it 'returns an empty array' do
        expect(reader.files_by_digest('xyz')).to eq([])
      end
    end

    context 'when not found' do
      before do
        stub_request(:get, "https://purl-fetcher.stanford.edu/v1/purls/druid:xyz").
          to_return(status: 404)
      end

      it 'raises an error' do
        expect { reader.files_by_digest('xyz') }.to raise_error(PurlFetcher::Client::NotFoundResponseError)
      end
    end
  end
end
