# frozen_string_literal: true

class User < ApplicationRecord
  acts_as_tenant(:organization)

  attribute :password, :string
  attribute :password_confirmation, :string

  belongs_to :organization
  has_many :activity_logs

  validate :validate_password!

  private

  def validate_password!
    return if password.blank? || password_confirmation.blank?
    return errors.add(:password, :confirmation) unless password == password_confirmation

    # Note: this is not meant to be a secure way to store passwords.
    password_digest = Digest::SHA256.hexdigest(password)
  end
end
