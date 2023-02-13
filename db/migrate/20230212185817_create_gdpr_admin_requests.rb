# frozen_string_literal: true

class CreateGdprAdminRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :gdpr_admin_requests do |t|
      t.references :tenant, null: false, foreign_key: { to_table: :organizations }
      t.references :requester, null: false, foreign_key: { to_table: :admin_users }
      t.string :request_type, null: false
      t.string :status, default: 'pending', null: false
      t.datetime :data_older_than, null: false

      t.timestamps
    end
  end
end
