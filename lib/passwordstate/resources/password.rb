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
                      :password, { redact: true },
                      :expiry_date, { is: Time },
                      :allow_export,
                      :web_user_id, { name: 'WebUser_ID' },
                      :web_password_id, { name: 'WebPassword_ID' } # rubocop:disable Style/BracesAroundHashParameters

      read_fields :password_id, { name: 'PasswordID' } # rubocop:disable Style/BracesAroundHashParameters

      # Things that can be set in a POST/PUT request
      write_fields :generate_password,
                   :generate_gen_field_password,
                   :password_reset_enabled,
                   :enable_password_reset_schedule,
                   :password_reset_schedule,
                   :add_days_to_expiry_date,
                   :script_id, { name: 'ScriptID' },
                   :password_list_id, { name: 'PasswordListID' }, # POST only
                   :privileged_account_id,
                   :heartbeat_enabled,
                   :heartbeat_schedule,
                   :validation_script_id, { name: 'ValidationScriptID' },
                   :host_name,
                   :ad_domain_netbios, { name: 'ADDomainNetBIOS' },
                   :validate_with_priv_account

      def history
        raise 'Password history only available on stored passwords' unless stored?
        PasswordHistory.get(client, password_id)
      end

      def delete(recycle = false, query = {})
        super query.merge(move_to_recycle_bin: recycle)
      end

      def add_dependency(data = {})
        raise 'Password dependency creation only available for stored passwords' unless stored?
        client.post :post, 'dependencies', body: data.merge(password_id: password_id)
      end

      def self.all(client, query = {})
        super client, { query_all: true }.merge(query)
      end

      def self.search(client, query = {})
        super client, query.merge(_api_path: 'searchpassword')
      end

      def self.generate(client, options = {})
        results = client.request(:get, 'generatepassword', query: options).map { |r| r['Password'] }
        return results.first if results.count == 1
        results
      end
    end

    class PasswordHistory < Passwordstate::Resource
      read_only

      api_path 'passwordhistory'

      index_field :password_history_id

      read_fields :password_history_id, { name: 'PasswordHistoryID' },
                  :date_changed, { is: Time },
                  :password_list,
                  :user_id, { name: 'UserID' },
                  :first_name,
                  :surname

      # Password object fields
      read_fields :title,
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
                  :password, { redact: true },
                  :password_id, { name: 'PasswordID' },
                  :expiry_date, { is: Time },
                  :allow_export,
                  :web_user_id, { name: 'WebUser_ID' },
                  :web_password_id, { name: 'WebPassword_ID' } # rubocop:disable Style/BracesAroundHashParameters

      def get
        raise 'Not applicable'
      end
    end
  end
end
