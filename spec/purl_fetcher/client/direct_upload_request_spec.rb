# frozen_string_literal: true

RSpec.describe PurlFetcher::Client::DirectUploadRequest do
  describe '.from_file' do
    subject(:from_file) do
      described_class.from_file(hexdigest: "6f5902ac237024bdd0c176cb93063dc4",
                                       byte_size: 12,
                                       file_name: 'file1.png',
                                       content_type:)
    end
    context "when content_type is empty string" do
      let(:content_type) { '' }

      it 'sets content_type application/octet-stream' do
        expect(from_file).to have_attributes(
            filename: 'file1.png', content_type: 'application/octet-stream', byte_size: 12,
            checksum: 'b1kCrCNwJL3QwXbLkwY9xA=='
          )
      end
    end

    context "when content_type is nil" do
      let(:content_type) { nil }

      it 'sets nil content_type to application/octet-stream' do
        expect(from_file).to have_attributes(
            filename: 'file1.png', content_type: 'application/octet-stream', byte_size: 12,
            checksum: 'b1kCrCNwJL3QwXbLkwY9xA=='
          )
      end
    end

    context "when content_type is application/xml" do
      let(:content_type) { 'application/xml' }

      it 'leaves content_type alone' do
        expect(from_file).to have_attributes(
            filename: 'file1.png', content_type: 'application/xml', byte_size: 12,
            checksum: 'b1kCrCNwJL3QwXbLkwY9xA=='
          )
      end
    end

    context "when content_type has extra part after semicolon" do
      let(:content_type) { 'application/x-stata-dta;version=14' }

      it 'trims it' do
        expect(from_file).to have_attributes(
            filename: 'file1.png', content_type: 'application/x-stata-dta', byte_size: 12,
            checksum: 'b1kCrCNwJL3QwXbLkwY9xA=='
          )
      end
    end
  end
end
