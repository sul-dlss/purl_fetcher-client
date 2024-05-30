# frozen_string_literal: true

module PurlFetcher
  class Client
    # High-level client for publishing and shelving.
    class PublishShelve
      def self.publish_and_shelve(...)
        new(...).publish_and_shelve
      end

      # @param [Cocina::Models::DRO,Cocina::Models::Collection] cocina the Cocina data object
      # @param [Hash<String,String>] filepath_map map of relative filepaths to absolute filepaths
      def initialize(cocina:, filepath_map:)
        @cocina = cocina
        @filepath_map = filepath_map
      end

      def publish_and_shelve
        logger.debug("Starting publish and shelve for: #{cocina.externalIdentifier}")

        direct_upload_responses = PurlFetcher::Client::UploadFiles.upload(file_metadata: file_metadata, filepath_map: filepath_map)
        file_uploads = direct_upload_responses.map { |response| [ response.filename, response.signed_id ] }.to_h

        PurlFetcher::Client::Publish.publish(cocina: cocina, file_uploads: file_uploads)
        logger.debug("Publish and shelve complete")
      end

      private

      attr_reader :cocina, :filepath_map

      def file_metadata
        return [] unless cocina.dro?

        cocina.structural.contains.flat_map do |fileset|
          fileset.structural.contains.select { |file| filepath_map.include?(file.filename) }.map do |file|
            direct_upload_request_for(file)
          end
        end
      end

      def direct_upload_request_for(cocina_file)
        PurlFetcher::Client::DirectUploadRequest.from_file(
          hexdigest: md5_for(cocina_file),
          byte_size: size_for(cocina_file),
          content_type: "application/octet-stream",
          file_name: cocina_file.filename
        )
      end

      def md5_for(cocina_file)
        cocina_file.hasMessageDigests.find { |digest| digest.type == "md5" }.digest
      end

      def size_for(cocina_file)
        return cocina_file.size if cocina_file.size.present? && cocina_file.size.positive?

        File.size(filepath_map[cocina_file.filename])
      end

      def logger
        Client.config.logger
      end
    end
  end
end
