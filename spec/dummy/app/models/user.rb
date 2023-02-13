# frozen_string_literal: true

class User < ApplicationRecord
  acts_as_tenant(:organization)

  belongs_to :organization
  has_many :activity_logs

  accepts_nested_attributes_for :activity_logs
end
