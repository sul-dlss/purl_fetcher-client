# frozen_string_literal: true

RSpec.describe PurlFetcher::Client::Withdraw do
  let(:druid) { "druid:bx911tp9024" }

  describe '.withdraw' do
    let(:fake_instance) { instance_double(described_class, withdraw: nil) }

    before do
      allow(described_class).to receive(:new).and_return(fake_instance)
    end

    it 'invokes #withdraw on a new instance' do
      described_class.withdraw(druid:, version: '2')
      expect(fake_instance).to have_received(:withdraw).once
    end
  end

  describe '.restore' do
    let(:fake_instance) { instance_double(described_class, restore: nil) }

    before do
      allow(described_class).to receive(:new).and_return(fake_instance)
    end

    it 'invokes #restore on a new instance' do
      described_class.restore(druid:, version: '2')
      expect(fake_instance).to have_received(:restore).once
    end
  end

  describe '#withdraw' do
    subject(:withdraw) do
      described_class.new(druid:, version: '2').withdraw
    end

    before do
      PurlFetcher::Client.configure(
        url: 'https://purl-fetcher.example.edu'
      )
      allow(PurlFetcher::Client.instance).to receive_messages(put: {})
    end

    it 'PUTS to the withdraw endpoint' do
      withdraw
      expect(PurlFetcher::Client.instance).to have_received(:put).with(path: "/v1/purls/druid:bx911tp9024/versions/2/withdraw")
    end
  end

  describe '#restore' do
    subject(:restore) do
      described_class.new(druid:, version: '2').restore
    end

    before do
      PurlFetcher::Client.configure(
        url: 'https://purl-fetcher.example.edu'
      )
      allow(PurlFetcher::Client.instance).to receive_messages(put: {})
    end

    it 'PUTS to the restore endpoint' do
      restore
      expect(PurlFetcher::Client.instance).to have_received(:put).with(path: "/v1/purls/druid:bx911tp9024/versions/2/restore")
    end
  end
end
