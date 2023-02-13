# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
