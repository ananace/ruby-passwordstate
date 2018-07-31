module Passwordstate
  module Resources
    class PasswordList < Passwordstate::Resource
      api_path 'passwordlists'

      index_field :password_list_id

      accessor_fields :password_list,
                      :description,
                      :image_file_name,
                      :guide,
                      :allow_export,
                      :private_password_list,
                      :time_based_access_required,
                      :handshake_approval_required,
                      :password_strength_policy_id, { name: 'PasswordStrengthPolicyID' },
                      :password_generator_id, { name: 'PasswordGeneratorID' },
                      :code_page,
                      :prevent_password_reuse,
                      :authentication_type,
                      :authentication_per_session,
                      :prevent_expiry_date_modification,
                      :reset_expiry_date,
                      :prevent_drag_drop,
                      :prevent_bad_password_use,
                      :provide_access_reason,
                      :password_reset_enabled,
                      :force_password_generator,
                      :hide_passwords,
                      :show_guide,
                      :enable_password_reset_schedule,
                      :password_reset_schedule,
                      :add_days_to_expiry_date

      read_fields :password_list_id, { name: 'PasswordListID' },
                  :tree_path,
                  :total_passwords,
                  :generator_name,
                  :policy_name

      def search_passwords(query = {})
        client.request(:get, "searchpasswords/#{password_list_id}", query: query).map do |entry|
          Passwordstate::Resources::Password.new entry.merge(_client: client)
        end
      end

      def passwords
        Passwordstate::ResourceList.new client, Passwordstate::Resources::Password,
                                        all_path: "passwords/#{password_list_id}",
                                        all_query: { query_all: nil },
                                        search_path: "searchpasswords/#{password_list_id}",
                                        object_data: { password_list_id: password_list_id }
      end

      def self.search(client, query = {})
        super client, query.merge(_api_path: 'searchpasswordlists')
      end
    end
  end
end
