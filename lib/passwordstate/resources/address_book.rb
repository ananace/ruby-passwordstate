# frozen_string_literal: true

module Passwordstate
  module Resources
    class AddressBook < Passwordstate::Resource
      api_path 'addressbook'

      index_field :address_book_id

      accessor_fields :first_name,
                      :surname,
                      :email_adress,
                      :company,
                      :business_phone,
                      :personal_phone,
                      :street,
                      :city,
                      :state,
                      :zipcode,
                      :country,
                      :notes,
                      :pass_phrase,
                      :global_contact

      read_fields :address_book_id, { name: 'AddressBookID' }
    end
  end
end
