# frozen_string_literal: true

require 'ipaddr'

module Passwordstate
  module Resources
    class Host < Passwordstate::Resource
      api_path 'hosts'

      index_field :host_name

      accessor_fields :host_name,
                      :host_type,
                      :operating_system,
                      :database_server_type,
                      :sql_instance_name, { name: 'SQLInstanceName' },
                      :database_port_number,
                      :remote_connection_type,
                      :remote_connection_port_number,
                      :remote_connection_parameters,
                      :tag,
                      :title,
                      :discovery_job_id, { name: 'DiscoveryJobID' },
                      :site_id, { name: 'SiteID' },
                      :internal_ip, { name: 'InternalIP', is: IPAddr },
                      :external_ip, { name: 'ExternalIP', is: IPAddr },
                      :mac_address, { name: 'MACAddress' },
                      :virtual_machine,
                      :virtual_machine_type,
                      :notes

      read_fields :host_id, { name: 'HostID' },
                  :site_location

      # TODO: API breaks if all fields aren't included
      nil_as_string true

      def self.available?(client)
        client.request :get, api_path
        true
      rescue Passwordstate::NotFoundError
        true
      rescue Passwordstate::ForbiddenError
        false
      end
    end
  end
end
