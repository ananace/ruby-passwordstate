module Passwordstate
  module Resources
    class Folder < Passwordstate::Resource
      api_path 'folders'

      accessor_fields :folder_name,
                      :description

      read_fields :folder_id, { name: 'FolderID' },
                  :tree_path,
                  :site_id, { name: 'SiteID' },
                  :site_location
    end
  end
end
