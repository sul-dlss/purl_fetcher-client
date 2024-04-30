# frozen_string_literal: true

require "digest"

module PurlFetcher
  class Client
    # This models the JSON that we send to the server.
    DirectUploadRequest = Data.define(:checksum, :byte_size, :content_type, :filename) do
      def self.from_file(hexdigest:, byte_size:, file_name:, content_type:)
        new(checksum: hex_to_base64_digest(hexdigest),
            byte_size: byte_size,
            content_type: clean_content_type(content_type),
            filename: file_name)
      end

      def to_h
        {
          blob: { filename: filename, byte_size: byte_size, checksum: checksum,
                  content_type: self.class.clean_content_type(content_type) }
        }
      end

      def to_json(*_args)
        JSON.generate(to_h)
      end

      def self.clean_content_type(content_type)
        return "application/octet-stream" if content_type.blank?

        # ActiveStorage is expecting "application/x-stata-dta" not "application/x-stata-dta;version=14"
        content_type.split(";").first
      end

      def self.hex_to_base64_digest(hexdigest)
        [ [ hexdigest ].pack("H*") ].pack("m0")
      end
    end
  end
end
