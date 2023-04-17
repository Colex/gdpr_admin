# frozen_string_literal: true

class UserDataPolicy < GdprAdmin::ApplicationDataPolicy
  before_process_record :check_role!

  def fields
    [
      { field: :email, method: ->(user) { "anonymized.user#{user.id}@company.org" } },
      { field: :first_name, method: -> { 'Anonymized' } },
      { field: :last_name, method: ->(user) { "User #{user.id}" } },
      { field: :password_digest, method: :anonymize_password },
    ]
  end

  def scope
    scope_by_date(User)
  end

  def subject_scope
    scope.where(email: request.subject)
  end

  def erase(user)
    erase_fields(user, fields, { anonymized_at: Time.zone.now })
  end

  private

  def check_role!(user)
    skip_record! if user.role == 'drummer'
  end
end
