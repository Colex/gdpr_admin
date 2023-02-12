# frozen_string_literal: true

class CreateGdprAdminTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :gdpr_admin_tasks do |t|
      t.references :tenant, null: false, foreign_key: { to_table: :organizations }
      t.references :requester, null: false, foreign_key: { to_table: :admin_users }
      t.string :request, null: false
      t.string :status, default: 'pending', null: false
      t.datetime :data_older_than

      t.timestamps
    end
  end
end
