# frozen_string_literal: true

module Passwordstate
  module Resources
    class Document < Passwordstate::Resource
      api_path 'document'

      index_field :document_id

      read_fields :document_id, { name: 'DocumentID' },
                  :document_name

      alias title document_name

      def self.all(client, store, **query)
        super client, query.merge(_api_path: "#{api_path}/#{validate_store! store}")
      end

      def self.search(client, store, **options)
        all client, store, **options
      end

      def self.get(client, store, object)
        super client, object, _api_path: "#{api_path}/#{validate_store! store}"
      end

      def self.post(client, store, data, **query)
        super client, data, query.merge(_api_path: "#{api_path}/#{validate_store! store}")
      end

      def self.put(client, store, data, **query)
        super client, data, query.merge(_api_path: "#{api_path}/#{validate_store! store}")
      end

      def self.delete(client, store, object, **query)
        super client, object, query.merge(_api_path: "#{api_path}/#{validate_store! store}")
      end

      class << self
        private

        def validate_store!(store)
          raise ArgumentError, 'Store must be one of password, passwordlist, folder' \
            unless %i[password passwordlist folder].include?(store.to_s.downcase.to_sym)

          store.to_s.downcase.to_sym
        end
      end
    end
  end
end
