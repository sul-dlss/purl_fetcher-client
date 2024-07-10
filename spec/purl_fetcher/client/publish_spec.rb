# frozen_string_literal: true

RSpec.describe PurlFetcher::Client::Publish do
  let(:cocina) { double("Cocina Model", externalIdentifier: "druid:bx911tp9024", to_h: {}) }
  let(:file_uploads) { { 'file2.txt' => '8eadd935-6764-45f5-8a22-8cae5974bbb0' } }

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
      described_class.new(cocina:, file_uploads:).publish
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
         body: "{\"object\":{},\"file_uploads\":{\"file2.txt\":\"8eadd935-6764-45f5-8a22-8cae5974bbb0\"}}",
         path: "/v1/resources")
    end
  end
end
