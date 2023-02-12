# frozen_string_literal: true

class ActivityLog < ApplicationRecord
  belongs_to :organization
  belongs_to :user
end
