# frozen_string_literal: true

RSpec.describe PurlFetcher::Client::LegacyPublish do
  let(:cocina) { double("Cocina Model", externalIdentifier: "druid:bx911tp9024", to_json: "{}") }

  describe '.publish' do
    let(:fake_instance) { instance_double(described_class, publish: nil) }

    before do
      allow(described_class).to receive(:new).and_return(fake_instance)
    end

    it 'invokes #publish on a new instance' do
      described_class.publish(cocina:)
      expect(fake_instance).to have_received(:publish).once
    end
  end

  describe '#publish' do
    subject(:publish) do
      described_class.new(cocina:).publish
    end

    before do
      PurlFetcher::Client.configure(
        url: 'https://purl-fetcher.example.edu'
      )
      allow(PurlFetcher::Client.instance).to receive_messages(post: {})
    end

    it 'POST provided metadata to the publish endpoint' do
      publish
      expect(PurlFetcher::Client.instance).to have_received(:post).with(
         body: '{}',
         path: "/purls/druid:bx911tp9024")
    end
  end
end
