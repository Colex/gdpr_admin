# frozen_string_literal: true

class ContactDataPolicy < GdprAdmin::ApplicationDataPolicy
  def fields
    [
      { field: :name, method: :anonymize_name },
      { field: :first_name, method: :anonymize_first_name },
      { field: :last_name, method: :anonymize_last_name },
      { field: :email, method: :anonymize_email },
      { field: :gender, method: :skip },
      { field: :company, method: :anonymize_company },
      { field: :job_title, method: :nilify },
      { field: :phone_number, method: :anonymize_phone_number },
      { field: :street_address1, method: :anonymize_street_address },
      { field: :street_address2, method: -> { Faker::Address.secondary_address } },
      { field: :city, method: :anonymize_city },
      { field: :state, method: :anonymize_state },
      { field: :zip, method: :anonymize_zip },
      { field: :country, method: :anonymize_country },
      { field: :country_code2, method: :anonymize_country_code2 },
      { field: :country_code3, method: :anonymize_country_code3 },
    ]
  end

  def scope
    Contact.where(updated_at: ...request.data_older_than)
  end

  def erase(contact)
    erase_fields(contact, fields, { anonymized_at: Time.zone.now })
  end
end
