# frozen_string_literal: true

class AddSubjectToGdprAdminRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :gdpr_admin_requests, :subject, :string
  end
end
