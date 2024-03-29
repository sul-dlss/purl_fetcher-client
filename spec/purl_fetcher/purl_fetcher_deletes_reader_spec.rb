require 'spec_helper'

RSpec.describe PurlFetcher::Client::DeletesReader do
  subject(:reader) { described_class.new('', settings) }
  let(:settings) { { 'purl_fetcher.target' => 'Searchworks' } }

  describe '#each' do
    before do
      if defined? JRUBY_VERSION
        expect(Manticore).to receive(:get).with(%r{/docs/deletes}, query: anything).and_return(deletes_response)
        expect(Manticore).to receive(:get).with(%r{/docs/changes}, query: anything).and_return(changes_response)
      else
        expect(HTTP).to receive(:get).with(%r{/docs/deletes}, params: anything).and_return(deletes_response)
        expect(HTTP).to receive(:get).with(%r{/docs/changes}, params: anything).and_return(changes_response)
      end
    end

    let(:deletes_response) { double(body: deletes_body, code: 200) }
    let(:changes_response) { double(body: changes_body, code: 200) }

    let(:deletes_body) {
      {
        deletes: [
          { druid: 'x' },
          { druid: 'y' },
        ],
        pages: { }
      }.to_json
    }

    let(:changes_body) {
      {
        changes: [
          { druid: 'a' },
          { druid: 'b' },
          { druid: 'c' },
          { druid: 'z', false_targets: ['Searchworks'] }
        ],
        pages: { }
      }.to_json
    }

    it 'returns objects from the purl-fetcher deletes api and any changed objects that are marked as a false target' do
      expect(reader.map { |x| x.druid }).to eq ['x', 'y', 'z']
    end
  end
end
