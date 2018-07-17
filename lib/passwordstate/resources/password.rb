module Passwordstate
  module Resources
    class Password < Passwordstate::Resource
      api_path 'passwords'

      index_field :password_id

      accessor_fields :title,
                      :domain,
                      :host_name,
                      :user_name,
                      :description,
                      :generic_field_1,
                      :generic_field_2,
                      :generic_field_3,
                      :generic_field_4,
                      :generic_field_5,
                      :generic_field_6,
                      :generic_field_7,
                      :generic_field_8,
                      :generic_field_9,
                      :generic_field_10,
                      :account_type_id, { name: 'AccountTypeID' },
                      :account_type,
                      :notes,
                      :url,
                      :password,
                      :expiry_date, { is: Time },
                      :allow_export,
                      :web_user_id, { name: 'WebUser_ID' },
                      :web_password_id, { name: 'WebPassword_ID' } # rubocop:disable Style/BracesAroundHashParameters

      read_fields :password_id, { name: 'PasswordID' } # rubocop:disable Style/BracesAroundHashParameters

      def self.generate(client, options = {})
        client.request(:get, 'generatepassword/', query: options).first['Password']
      end
    end
  end
end
