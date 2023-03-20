require 'spec_helper'

RSpec.describe PurlFetcher::Client::Reader do
  subject(:reader) { described_class.new('', settings) }
  let(:settings) { { 'purl_fetcher.target' => 'Searchworks' } }

  describe '#each' do
    before do
      if defined? JRUBY_VERSION
        expect(Manticore).to receive(:get).with(%r{/docs/changes}, query: hash_including(target: 'Searchworks')).and_return(response)
      else
        expect(HTTP).to receive(:get).with(%r{/docs/changes}, params: hash_including(target: 'Searchworks')).and_return(response)
      end
    end

    let(:response) { double(body: body, code: 200) }

    let(:body) {
      {
        changes: [
          { druid: 'x', true_targets: ['Searchworks'] },
          { druid: 'y', true_targets: ['Searchworks'] },
          { druid: 'z', true_targets: ['SomethingElse'] }
        ],
        pages: { }
      }.to_json
    }

    it 'returns objects from the purl-fetcher api' do
      expect(reader.map { |x| x.druid }).to eq ['x', 'y']
    end

    context 'when the status is not successful' do
      let(:response) {
        double(body: body, code: 410)
      }
      it "raises an error" do
        expect { reader.map {} }.to raise_error PurlFetcher::Client::Error, 'Unsuccessful response from purl-fetcher'
      end
    end
  end

  describe '#collection_members' do
    before do
      if defined? JRUBY_VERSION
        expect(Manticore).to receive(:get).with(%r{/collections/druid:xyz/purls}, query: hash_including(page: 1)).and_return(response)
      else
        expect(HTTP).to receive(:get).with(%r{/collections/druid:xyz/purls}, params: hash_including(page: 1)).and_return(response)
      end
    end

    let(:response) {
      double(body: body, code: 200)
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
