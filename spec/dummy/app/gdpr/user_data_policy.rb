# frozen_string_literal: true

class UserDataPolicy < GdprAdmin::ApplicationDataPolicy
  def fields
    [
      { field: :email, method: ->(user) { "anonymized.user#{user.id}@company.org" } },
      { field: :first_name, method: -> { 'Anonymized' } },
      { field: :last_name, method: ->(user) { "User #{user.id}" } },
      { field: :password_digest, method: :anonymize_password },
    ]
  end

  def scope
    User.where(updated_at: ...request.data_older_than)
  end

  def erase(user)
    erase_fields(user, fields, { anonymized_at: Time.zone.now })
  end
end
