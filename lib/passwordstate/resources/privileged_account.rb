# frozen_string_literal: true

module Passwordstate
  module Resources
    class PrivilegedAccount < Passwordstate::Resource
      api_path 'privaccount'

      index_field :privileged_account_id

      accessor_fields :description,
                      :user_name,
                      :password,
                      :password_id, { name: 'PasswordID' },
                      :key_type,
                      :pass_phrase,
                      :private_key,
                      :site_id, { name: 'SiteID' },
                      :account_type,
                      :enable_password

      read_fields :privileged_account_id
    end

    class PrivilegedAccountPermission < Permission
      api_path 'privaccountpermissions'

      index_field :privileged_account_id

      read_fields :privileged_account_id, { name: 'PrivilegedAccountID' }
    end
  end
end
