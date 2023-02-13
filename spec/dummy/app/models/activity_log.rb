# frozen_string_literal: true

class ActivityLog < ApplicationRecord
  acts_as_tenant(:organization)

  belongs_to :user

  before_validation :set_organization

  private

  def set_organization
    self.organization = user.organization
  end
end
