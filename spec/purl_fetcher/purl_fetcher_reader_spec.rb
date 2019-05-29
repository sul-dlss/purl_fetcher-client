require 'spec_helper'

RSpec.describe PurlFetcher::Client::Reader do
  subject(:reader) { described_class.new('', settings) }
  let(:settings) { { 'purl_fetcher.target' => 'Searchworks' } }

  describe '#each' do
    before do
      if defined? JRUBY_VERSION
        expect(Manticore).to receive(:get).with(%r{/docs/changes}, query: hash_including(target: 'Searchworks')).and_return(double(body: body))
      else
        expect(HTTP).to receive(:get).with(%r{/docs/changes}, params: hash_including(target: 'Searchworks')).and_return(double(body: body))
      end
    end

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
  end
end
