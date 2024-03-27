# frozen_string_literal: true

module Passwordstate
  module Resources
    class PasswordList < Passwordstate::Resource
      HideConfig = Struct.new(:view, :modify, :admin) do
        def self.parse(str)
          view, modify, admin = str.split(':').map { |b| b.to_s.downcase == 'true' }

          new view, modify, admin
        end

        def to_s
          "#{view}:#{modify}:#{admin}"
        end
      end

      api_path 'passwordlists'
      acceptable_methods :CR

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
                      :hide_passwords, { is: HideConfig },
                      :show_guide,
                      :enable_password_reset_schedule,
                      :password_reset_schedule,
                      :add_to_expiry_date,
                      :add_to_expiry_date_interval,
                      :one_time_passwords

      read_fields :password_list_id, { name: 'PasswordListID' },
                  :tree_path,
                  :total_passwords,
                  :generator_name,
                  :policy_name

      write_fields :copy_settings_from_password_list_id, { name: 'CopySettinsgFromPasswordListID' },
                   :copy_settings_from_template_id, { name: 'CopySettingsFromTemplateID' },
                   :link_to_template,
                   :copy_permissions_from_password_list_id, { name: 'CopyPermissionsFromPasswordListID' },
                   :copy_permissions_from_template_id, { name: 'CopyPermissionsFromTemplateID' },
                   :nest_under_folder_id, { name: 'NestUnderFolderID' },
                   :apply_permissions_for_user_id, { name: 'ApplyPermissionsForUserID' },
                   :apply_permissions_for_security_group_id, { name: 'ApplyPermissionsForSecurityGroupID' },
                   :apply_permissions_for_security_group_name,
                   :permission,
                   :site_id, { name: 'SiteID' }

      alias title password_list

      def self.search(client, **query)
        super(client, **query.merge(_api_path: 'searchpasswordlists'))
      end

      def passwords
        Passwordstate::ResourceList.new Passwordstate::Resources::Password,
                                        client: client,
                                        all_path: "passwords/#{password_list_id}",
                                        all_query: { query_all: nil },
                                        search_path: "searchpasswords/#{password_list_id}",
                                        object_data: { password_list_id: password_list_id }
      end

      def permissions
        client.require_version('>= 8.4.8449')
        PasswordListPermission.new(_client: client, password_list_id: password_list_id)
      end

      def full_path(unix: false)
        path = [tree_path]
        path << password_list unless tree_path.end_with? password_list

        path.compact.join('\\').tap do |full|
          full.tr!('\\', '/') if unix
        end
      end
    end

    class PasswordListPermission < Permission
      api_path 'passwordlistpermissions'

      index_field :password_list_id

      read_fields :password_list_id, { name: 'PasswordListID' }
    end
  end
end
