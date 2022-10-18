# frozen_string_literal: true

module Passwordstate
  module Resources
    class ActiveDirectory < Passwordstate::Resource
      api_path 'activedirectory'

      index_field :ad_domain_id

      accessor_fields :ad_domain_netbios, { name: 'ADDomainNetBIOS' },
                      :ad_domain_ldap, { name: 'ADDomainLDAP' },
                      :fqdn, { name: 'FQDN' },
                      :default_domain,
                      :pa_read_id, { name: 'PAReadID' },
                      :site_id, { name: 'SiteID' },
                      :used_for_authentication,
                      :protocol,
                      :domain_controller_fqdn, { name: 'DomainControllerFQDN' }

      read_fields :ad_domain_id, { name: 'ADDomainID' }
    end
  end
end
