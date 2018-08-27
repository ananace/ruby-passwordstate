module Passwordstate
  module Resources
    class Permission < Passwordstate::Resource
      accessor_fields :permission

      # TODO: Only one of the apply_* can be set at a time
      write_fields :apply_permissions_for_user_id, { name: 'ApplyPermissionsForUserID' },
                   :apply_permissions_for_security_group_id, { name: 'ApplyPermissionsForSecurityGroupID' },
                   :apply_permissions_for_security_group_name

      def get
        raise 'Not applicable'
      end
    end
  end
end
