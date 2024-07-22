# frozen_string_literal: true

RSpec.describe PurlFetcher::Client::Unpublish do
  let(:druid) { "druid:bx911tp9024" }

  describe '.unpublish' do
    let(:fake_instance) { instance_double(described_class, unpublish: nil) }

    before do
      allow(described_class).to receive(:new).and_return(fake_instance)
    end

    it 'invokes #unpublish on a new instance' do
      described_class.unpublish(druid:, version: '2')
      expect(fake_instance).to have_received(:unpublish).once
    end
  end

  describe '#unpublish' do
    subject(:unpublish) do
      described_class.new(druid:, version: '2').unpublish
    end

    before do
      PurlFetcher::Client.configure(
        url: 'https://purl-fetcher.example.edu'
      )
      allow(PurlFetcher::Client.instance).to receive_messages(delete: {})
    end

    it 'DELETE to the unpublish endpoint' do
      unpublish
      expect(PurlFetcher::Client.instance).to have_received(:delete).with(path: "/purls/druid:bx911tp9024", params: { version: "2" })
    end
  end
end
