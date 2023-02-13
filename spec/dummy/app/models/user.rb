# frozen_string_literal: true

class User < ApplicationRecord
  acts_as_tenant(:organization)

  has_many :activity_logs
end
