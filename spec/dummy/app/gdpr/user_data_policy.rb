# frozen_string_literal: true

class UserDataPolicy < GdprAdmin::ApplicationDataPolicy
  def scope
    User.where(updated_at: ...request.data_older_than)
  end

  def erase(user)
    user.update_columns(
      email: "anonymized.user#{user.id}@company.org",
      first_name: 'Anonymized',
      last_name: "User #{user.id}",
      password_digest: '654321',
    )
  end
end
