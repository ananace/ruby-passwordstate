# frozen_string_literal: true

module Passwordstate
  module Resources
    class Password < Passwordstate::Resource
      api_path 'passwords'

      index_field :password_id

      # rubocop:disable Naming/VariableNumber
      accessor_fields :title,
                      :domain,
                      :host_name,
                      :user_name,
                      :description,
                      :generic_field_1, { name: 'GenericField1' },
                      :generic_field_2, { name: 'GenericField2' },
                      :generic_field_3, { name: 'GenericField3' },
                      :generic_field_4, { name: 'GenericField4' },
                      :generic_field_5, { name: 'GenericField5' },
                      :generic_field_6, { name: 'GenericField6' },
                      :generic_field_7, { name: 'GenericField7' },
                      :generic_field_8, { name: 'GenericField8' },
                      :generic_field_9, { name: 'GenericField9' },
                      :generic_field_10, { name: 'GenericField10' },
                      :generic_field_info,
                      :account_type_id, { name: 'AccountTypeID' },
                      :notes,
                      :url,
                      :password, { redact: true },
                      :expiry_date, { is: Time },
                      :allow_export,
                      :web_user_id, { name: 'WebUser_ID' },
                      :web_password_id, { name: 'WebPassword_ID' },
                      :password_list_id, { name: 'PasswordListID' } # NB: POST only
      # rubocop:enable Naming/VariableNumber

      read_fields :account_type,
                  :password_id, { name: 'PasswordID' },
                  :password_list,
                  :otp,
                  # For 'Managed' passwords
                  :status,
                  :current_password,
                  :new_password

      # Things that can be set in a POST/PUT request
      # TODO: Do this properly
      write_fields :generate_password,
                   :generate_gen_field_password,
                   :password_reset_enabled,
                   :enable_password_reset_schedule,
                   :password_reset_schedule,
                   :add_days_to_expiry_date,
                   :script_id, { name: 'ScriptID' },
                   :privileged_account_id,
                   :heartbeat_enabled,
                   :heartbeat_schedule,
                   :validation_script_id, { name: 'ValidationScriptID' },
                   :ad_domain_netbios, { name: 'ADDomainNetBIOS' },
                   :validate_with_priv_account

      def otp!
        client.request(:get, "onetimepassword/#{password_id}").first['OTP']
      end

      def check_in
        client.request :get, "passwords/#{password_id}", query: self.class.passwordstateify_hash(check_in: nil)
      end

      def send_selfdestruct(email, expires_at:, view_count:, reason: nil, **params)
        data = {
          password_id: password_id,
          to_email_address: email,
          expires_at: expires_at,
          no_views: view_count
        }
        data[:message] = params[:message] if params.key? :message
        data[:prefix_message_content] = params[:prefix_message] if params.key? :prefix_message
        data[:append_message_content] = params[:suffix_message] if params.key? :suffix_message
        data[:to_first_name] = params[:name] if params.key? :name
        data[:email_subject] = params[:subject] if params.key? :subject
        data[:email_body] = params[:body] if params.key? :body
        data[:passphrase] = params[:passphrase] if params.key? :passphrase
        data[:reason] = reason if reason

        client.request :post, 'selfdestruct', data: data
      end

      def history
        raise 'Password history only available on stored passwords' unless stored?

        Passwordstate::ResourceList.new PasswordHistory,
                                        client: client,
                                        all_path: "passwordhistory/#{password_id}",
                                        only: :all
      end

      def permissions
        client.require_version('>= 8.4.8449')
        PasswordPermission.new(_client: client, password_id: password_id)
      end

      def delete(recycle: false, **query)
        super(**query.merge(move_to_recycle_bin: recycle))
      end

      def add_dependency(**data)
        raise 'Password dependency creation only available for stored passwords' unless stored?

        client.request :post, 'dependencies', body: self.class.passwordstatify_hash(data.merge(password_id: password_id))
      end

      def self.all(client, **query)
        query = { query_all: true }.merge(query)
        super(client, **query)
      end

      def self.search(client, **query)
        query = { _api_path: 'searchpasswords' }.merge(query)
        super(client, **query)
      end

      def self.generate(client, **options)
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
      # rubocop:disable Naming/VariableNumber
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
                  :web_password_id, { name: 'WebPassword_ID' }
      # rubocop:enable Naming/VariableNumber

      def get
        raise 'Not applicable'
      end
    end

    class PasswordPermission < Permission
      api_path 'passwordpermissions'

      index_field :password_id

      read_fields :password_id, { name: 'PasswordID' }
    end
  end
end
