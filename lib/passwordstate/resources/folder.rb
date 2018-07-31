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

      def password_lists
        Passwordstate::ResourceList.new client, Passwordstate::Resources::PasswordList,
                                        search_query: { tree_path: tree_path },
                                        all_path: 'searchpasswordlists',
                                        all_query: { tree_path: tree_path },
                                        object_data: { nest_undef_folder_id: folder_id }
      end
    end
  end
end
