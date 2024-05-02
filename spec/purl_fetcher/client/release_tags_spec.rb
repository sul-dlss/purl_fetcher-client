# frozen_string_literal: true

RSpec.describe PurlFetcher::Client::ReleaseTags do
  let(:druid) { "druid:bx911tp9024" }
  describe '.release' do
    let(:fake_instance) { instance_double(described_class, release: nil) }

    before do
      allow(described_class).to receive(:new).and_return(fake_instance)
    end

    it 'invokes #release on a new instance' do
      described_class.release(druid:)
      expect(fake_instance).to have_received(:release).once
    end
  end

  describe '#release' do
    subject(:release) do
      described_class.new(druid:, index:, delete:).release
    end

    let(:index) { [ 'Searchworks', "Earthworks" ] }
    let(:delete) { [ 'PURL sitemap' ] }

    before do
      PurlFetcher::Client.configure(
        url: 'https://purl-fetcher.example.edu'
      )
      allow(PurlFetcher::Client.instance).to receive_messages(put: {})
    end

    it 'PUTS provided metadata to the release endpoint' do
      release
      expect(PurlFetcher::Client.instance).to have_received(:put).with(
         body: '{"index":["Searchworks","Earthworks"],"delete":["PURL sitemap"]}',
         path: "/v1/released/druid:bx911tp9024")
    end
  end
end
