# frozen_string_literal: true

RSpec.describe PurlFetcher::Client::Mods do
  let(:cocina) do
    { cocina_version: '0.97.0' }
  end

  describe '.create' do
    let(:fake_instance) { instance_double(described_class, create: nil) }

    before do
      allow(described_class).to receive(:new).and_return(fake_instance)
    end

    it 'invokes #create on a new instance' do
      described_class.create(cocina:)
      expect(described_class).to have_received(:new).with(cocina:)
      expect(fake_instance).to have_received(:create)
    end
  end

  describe '#create' do
    subject(:create) do
      described_class.new(cocina:).create
    end

    before do
      PurlFetcher::Client.configure(
        url: 'https://purl-fetcher.example.edu'
      )
      allow(PurlFetcher::Client.instance).to receive_messages(post: "<mods></mods>")
    end

    it 'POST provided metadata to the mods endpoint' do
      create
      expect(PurlFetcher::Client.instance).to have_received(:post).with(body: cocina.to_json,
         path: "/v1/mods")
    end
  end
end
