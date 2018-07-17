module Passwordstate
  module Resources
    class Report < Passwordstate::Resource
      REPORT_PARAMETERS = {
        1  => %i[user_id],
        2  => %i[user_id site_id],
        3  => %i[user_id duration],
        4  => %i[user_id site_id duration],
        5  => %i[duration],
        6  => %i[],
        7  => %i[user_id site_id duration],
        8  => %i[],
        9  => %i[],
        10 => %i[duration],
        11 => %i[duration],
        12 => %i[site_id],
        13 => %i[site_id],
        14 => %i[site_i],
        15 => %i[site_id],
        16 => %i[site_id],
        17 => %i[duration password_list_ids query_expired_passwords],
        18 => %i[site_id duration],
        19 => %i[site_id],
        20 => %i[site_id],
        21 => %i[site_id],
        22 => %i[site_id],
        23 => %i[site_id],
        24 => %i[site_id user_id],
        25 => %i[site_id security_group_name],
        26 => %i[duration],
        27 => %i[duration],
        28 => %i[duration],
        29 => %i[duration],
        30 => %i[duration],
        31 => %i[duration],
        32 => %i[duration],
        33 => %i[duration],
        34 => %i[duration]
      }.freeze

      api_path 'reporting'

      index_field :report_id

      read_fields :report_id, { name: 'ReportID' },
                  :site_id, { name: 'SiteID' },
                  :user_id, { name: 'UserID' },
                  :security_group_name,
                  :duration,
                  :password_list_ids, { name: 'PasswordListIDs' },
                  :query_expired_passwords
    end
  end
end
