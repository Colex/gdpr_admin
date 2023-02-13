# frozen_string_literal: true

class UserDataPolicy < GdprAdmin::ApplicationDataPolicy
  def scope
    User.all
  end

  def erase(user)
    password = SecureRandom.hex(32)
    user.update_columns(
      email: "anonymized.user#{user.id}@company.org",
      first_name: 'Anonymized',
      last_name: "User #{user.id}",
      password_digest: User.digest_password(password),
    )
  end
end
