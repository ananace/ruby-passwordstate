# frozen_string_literal: true

module Passwordstate
  module Resources
    class RemoteSite < Passwordstate::Resource
      api_path 'remotesitelocations'

      index_field :site_id

      accessor_fields :site_location,
                      :poll_frequency,
                      :maintenance_start,
                      :maintenance_end,
                      :gateway_url, { name: 'GatewayURL' },
                      :purge_session_recordings,
                      :discovery_threads,
                      :allowed_ip_ranges, { name: 'AllowedIPRanges' }

      read_fields :site_id, { name: 'SiteID' }

      def self.installer_instructions
        client.request :get, "#{api_path}/exportinstallerinstructions"
      end
    end
  end
end
