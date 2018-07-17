module Passwordstate
  module Resources
    class Document < Passwordstate::Resource
      api_path 'document'

      index_field :document_id

      read_fields :document_id, { name: 'DocumentID' },
                  :document_name

      def self.search(client, store, options = {})
        client.request :get, "#{api_path}/#{store}/", query: options
      end

      def self.get(client, store, object)
        client.request :get, "#{api_path}/#{store}/#{object}"
      end
    end
  end
end
