# frozen_string_literal: true

module PurlFetcher
  class Client
    DirectUploadResponse = Data.define(:id, :key, :checksum, :byte_size, :content_type,
                                      :filename, :metadata, :created_at, :direct_upload,
                                      :signed_id, :service_name) do
                                        def with_filename(filename)
                                          self.class.new(**deconstruct_keys(nil).merge(filename:))
                                        end
                                      end
  end
end
