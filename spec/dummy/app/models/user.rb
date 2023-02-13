# frozen_string_literal: true

class User < ApplicationRecord
  acts_as_tenant(:organization)

  attr_reader :password, :password_confirmation

  belongs_to :organization
  has_many :activity_logs

  validate :validate_password!

  def password=(value)
    @password = value
    self.password_digest = Digest::SHA256.hexdigest(password)
  end

  def password_confirmation=(value)
    @password_confirmation = value
  end

  private

  def validate_password!
    return if password.blank? || password_confirmation.blank?

    errors.add(:password, :confirmation) unless password == password_confirmation
  end
end
