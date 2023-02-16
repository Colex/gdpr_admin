# frozen_string_literal: true

module GdprAdmin
  class DataRetentionPolicy < ApplicationRecord
    include GdprAdmin::DataRetentionPolicyConcern
  end
end
