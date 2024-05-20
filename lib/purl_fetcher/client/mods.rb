# frozen_string_literal: true

module PurlFetcher
  class Client
    # Create a MODS represenation of Cocina JSON
    class Mods
      # @param [Cocina::Models::Dro] cocina the Cocina JSON representation of the object
      def self.create(cocina:)
        new(cocina:).create
      end

      # @param [Cocina::Models::Dro] cocina the Cocina JSON representation of the object
      def initialize(cocina:)
        @cocina = cocina
      end

      def create
        response = client.post(path:, body:)
      end

      private

      attr_reader :cocina

      def body
        cocina.to_json
      end

      def client
        Client.instance
      end

      def path
        "/v1/mods"
      end
    end
  end
end
