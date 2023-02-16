# frozen_string_literal: true

class CreateGdprAdminDataRetentionPolicies < ActiveRecord::Migration[7.0]
  def change
    create_table :gdpr_admin_data_retention_policies do |t|
      t.references :tenant, null: false, foreign_key: { to_table: :organizations }, index: { unique: true }
      t.integer :period_in_days, null: false
      t.boolean :active, null: false, default: false
      t.datetime :last_run_at

      t.timestamps
    end
  end
end
