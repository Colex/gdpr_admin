# frozen_string_literal: true

class CreateContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :contacts do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name
      t.string :first_name
      t.string :last_name
      t.string :gender
      t.string :email
      t.string :phone_number
      t.string :street_address1
      t.string :street_address2
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.string :country_code2
      t.string :country_code3
      t.string :company
      t.string :job_title
      t.datetime :anonymized_at

      t.timestamps
    end
  end
end
