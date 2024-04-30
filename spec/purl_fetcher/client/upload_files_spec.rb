# frozen_string_literal: true

RSpec.describe PurlFetcher::Client::UploadFiles do
  describe '.upload' do
    let(:fake_instance) { instance_double(described_class, upload: nil) }

    before do
      allow(described_class).to receive(:new).and_return(fake_instance)
    end

    it 'invokes #upload on a new instance' do
      described_class.upload(
        file_metadata: {},
        filepath_map: {}
      )
      expect(fake_instance).to have_received(:upload).once
    end
  end

  describe '#upload' do
    subject(:uploader) do
      described_class.new(file_metadata: file_metadata, filepath_map: filepath_map)
    end

    let(:fake_post_response) do
      {
        id: 26,
        key: "f8u88eq34lcn058lkuvqlmgxiqxw",
        filename: 'file1.txt',
        metadata: {},
        created_at: "2024-04-30T16:58:53.465Z",
        service_name: "local",
        content_type: "text/plain",
        byte_size: 27,
        checksum: 'hagfaf2F1Cx0r3jnHtIe9Q==',
        signed_id: 'BaHBLZz09Iiw',
        direct_upload: { 'url' => 'https://sdr-api.example.edu/v1/disk/BaHBLZz09Iiw' }
      }
    end
    let(:file_metadata) do
      {
        'file1.txt' => PurlFetcher::Client::DirectUploadRequest.new(
          checksum: '123',
          byte_size: 10_000,
          content_type: 'image/tiff',
          filename: 'image.tiff'
        )
      }
    end
    let(:filepath_map) do
      {
        'file1.txt' => File.expand_path('spec/fixtures/file1.txt')
      }
    end

    before do
      PurlFetcher::Client.configure(
        url: 'https://purl-fetcher.example.edu'
      )
      allow(PurlFetcher::Client.instance).to receive_messages(
        post: fake_post_response,
        put: {}
      )
    end

    it 'returns a list of upload responses' do
      expect(uploader.upload.count).to eq(filepath_map.count)
      expect(uploader.upload.first).to be_a(PurlFetcher::Client::DirectUploadResponse)
      expect(uploader.upload.first.filename).to eq('file1.txt')
    end

    it 'POSTs provided metadata to the uploads endpoint' do
      uploader.upload
      expect(PurlFetcher::Client.instance).to have_received(:post).once
    end

    it 'PUTs the provided files to the uploads endpoint' do
      uploader.upload
      expect(PurlFetcher::Client.instance).to have_received(:put).once
    end
  end
end
