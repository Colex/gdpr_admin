# frozen_string_literal: true

class User < ApplicationRecord
  acts_as_tenant(:organization)

  has_many :activity_logs

  private

  # Mimic devise's method for digesting passwords
  def password_digest(password)
    Digest::SHA256.hexdigest(password)
  end
end
