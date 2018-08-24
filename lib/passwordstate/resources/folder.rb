module Passwordstate
  module Resources
    class Folder < Passwordstate::Resource
      api_path 'folders'

      index_field :folder_id

      accessor_fields :folder_name,
                      :description

      read_fields :folder_id, { name: 'FolderID' },
                  :tree_path,
                  :site_id, { name: 'SiteID' },
                  :site_location

      alias title folder_name

      def password_lists
        Passwordstate::ResourceList.new client, Passwordstate::Resources::PasswordList,
                                        search_query: { tree_path: tree_path },
                                        all_path: 'searchpasswordlists',
                                        all_query: { tree_path: tree_path },
                                        object_data: { nest_undef_folder_id: folder_id }
      end

      def permissions
        client.require_version('>= 8.4.8449')
        FolderPermission.new(_client: client, folder_id: folder_id)
      end

      def full_path(unix = false)
        return tree_path.tr('\\', '/') if unix
        tree_path
      end
    end

    class FolderPermission < Passwordstate::Resource
      api_path 'folderpermissions'

      index_field :folder_id

      # TODO: Only one of the apply_* can be set at a time
      accessor_fields :permission,
                      :apply_permissions_for_user_id, { name: 'ApplyPermissionsForUserID' },
                      :apply_permissions_for_security_group_id, { name: 'ApplyPermissionsForSecurityGroupID' },
                      :apply_permissions_for_security_group_name

      read_fields :folder_id, { name: 'FolderID' } # rubocop:disable Style/BracesAroundHashParameters
    end
  end
end
