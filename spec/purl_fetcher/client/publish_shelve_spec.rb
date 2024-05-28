# frozen_string_literal: true

RSpec.describe PurlFetcher::Client::PublishShelve do
  let(:cocina) do
    build(:dro)
      .new(structural: {
             contains: [
               {
                 type: Cocina::Models::FileSetType.image,
                 externalIdentifier: 'https://cocina.sul.stanford.edu/fileSet/jt667tw2770-0001',
                 label: '',
                 version: 6,
                 structural: {
                   contains: [
                     {
                       type: Cocina::Models::ObjectType.file,
                       externalIdentifier: 'https://cocina.sul.stanford.edu/file/jt667tw2770-0001/jt667tw2770_00_0001.tif',
                       label: 'jt667tw2770_00_0001.tif',
                       filename: 'jt667tw2770_00_0001.tif',
                       size: 193_090_740,
                       version: 6,
                       hasMimeType: 'image/tiff',
                       hasMessageDigests: [
                         { type: 'sha1', digest: 'd71f1b739d4b3ff2bf199c8e3452a16c7a6609f0' },
                         { type: 'md5', digest: 'a695ccc6ed7a9c905ba917d7c284854e' }
                       ],
                       access: { view: 'dark', download: 'none' },
                       administrative: { publish: false, sdrPreserve: true, shelve: false },
                       presentation: { height: 6610, width: 9736 }
                     }, {
                       type: Cocina::Models::ObjectType.file,
                       externalIdentifier: 'https://cocina.sul.stanford.edu/file/jt667tw2770-0001/jt667tw2770_05_0001.jp2',
                       label: 'jt667tw2770_05_0001.jp2',
                       filename: 'images/jt667tw2770_05_0001.jp2',
                       size: 12_141_770,
                       version: 6,
                       hasMimeType: 'image/jp2',
                       hasMessageDigests: [
                         { type: 'sha1', digest: 'b6632c33619e3dd6268eb1504580285670f4c3b8' },
                         { type: 'md5', digest: '9f74085aa752de7404d31cb6bcc38a56' }
                       ],
                       access: { view: 'dark', download: 'none' },
                       administrative: { publish: false, sdrPreserve: true, shelve: false },
                       presentation: { height: 6610, width: 9736 }
                     }
                   ]
                 }
               }
             ],
             hasMemberOrders: [],
             isMemberOf: [ 'druid:zb871zd0767' ]
           })
  end

  let(:filepath_map) do
    {
      'jt667tw2770_00_0001.tif' => '/workspace/jt667tw2770_00_0001.tif',
      'images/jt667tw2770_05_0001.jp2' => '/workspace/images/jt667tw2770_05_0001.jp2'
    }
  end

  describe '.publish_and_shleve' do
    let(:fake_instance) { instance_double(described_class, publish_and_shelve: nil) }

    before do
      allow(described_class).to receive(:new).and_return(fake_instance)
    end

    it 'invokes #publish_and_shelve on a new instance' do
      described_class.publish_and_shelve(cocina:, filepath_map:)
      expect(fake_instance).to have_received(:publish_and_shelve).once
    end
  end

  describe '#publish_and_shelve' do
    subject(:publish_shelve) do
      described_class.new(cocina: cocina, filepath_map: filepath_map).publish_and_shelve
    end

    let(:direct_upload_responses) do
      [
        instance_double(PurlFetcher::Client::DirectUploadResponse,
          filename: 'jt667tw2770_00_0001.tif',
          signed_id: 'signed_id1'
        ),
        instance_double(PurlFetcher::Client::DirectUploadResponse,
          filename: 'images/jt667tw2770_05_0001.jp2',
          signed_id: 'signed_id2'
        )
      ]
    end

    let(:file_metadata) do
      [
        PurlFetcher::Client::DirectUploadRequest.new(checksum: "ppXMxu16nJBbqRfXwoSFTg==", byte_size: 193090740, content_type: "application/octet-stream", filename: "jt667tw2770_00_0001.tif"),
      PurlFetcher::Client::DirectUploadRequest.new(checksum: "n3QIWqdS3nQE0xy2vMOKVg==", byte_size: 12141770, content_type: "application/octet-stream", filename: "images/jt667tw2770_05_0001.jp2") ]
    end

    before do
      PurlFetcher::Client.configure(
        url: 'https://purl-fetcher.example.edu'
      )
      allow(PurlFetcher::Client::UploadFiles).to receive(:upload).and_return(direct_upload_responses)
      allow(PurlFetcher::Client::Publish).to receive(:publish)
    end

    it 'invokes UploadFiles and Publish' do
      publish_shelve

      expect(PurlFetcher::Client::UploadFiles).to have_received(:upload).with(file_metadata:, filepath_map: filepath_map)
      expect(PurlFetcher::Client::Publish).to have_received(:publish).with(cocina: cocina, file_uploads: { 'jt667tw2770_00_0001.tif' => 'signed_id1', 'images/jt667tw2770_05_0001.jp2' => 'signed_id2' })
    end
  end
end
