# frozen_string_literal: true

class CreateActivityLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :activity_logs do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :sign_in_ip
      t.string :city
      t.string :region
      t.string :country

      t.timestamps
    end
  end
end
