# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_02_16_171202) do
  create_table "activity_logs", force: :cascade do |t|
    t.integer "organization_id", null: false
    t.integer "user_id", null: false
    t.string "sign_in_ip"
    t.string "city"
    t.string "region"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_activity_logs_on_organization_id"
    t.index ["user_id"], name: "index_activity_logs_on_user_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "name"
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
  end

  create_table "contacts", force: :cascade do |t|
    t.integer "organization_id", null: false
    t.string "name"
    t.string "first_name"
    t.string "last_name"
    t.string "gender"
    t.string "email"
    t.string "phone_number"
    t.string "street_address1"
    t.string "street_address2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "country"
    t.string "country_code2"
    t.string "country_code3"
    t.string "company"
    t.string "job_title"
    t.datetime "anonymized_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_contacts_on_organization_id"
  end

  create_table "gdpr_admin_data_retention_policies", force: :cascade do |t|
    t.integer "tenant_id", null: false
    t.integer "period_in_days", null: false
    t.boolean "active", default: false, null: false
    t.datetime "last_run_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_gdpr_admin_data_retention_policies_on_tenant_id", unique: true
  end

  create_table "gdpr_admin_requests", force: :cascade do |t|
    t.integer "tenant_id", null: false
    t.integer "requester_id"
    t.string "request_type", null: false
    t.string "status", default: "pending", null: false
    t.datetime "data_older_than", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["requester_id"], name: "index_gdpr_admin_requests_on_requester_id"
    t.index ["tenant_id"], name: "index_gdpr_admin_requests_on_tenant_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "role", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "anonymized_at"
    t.integer "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.json "object"
    t.string "ip"
    t.datetime "created_at"
    t.json "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "activity_logs", "organizations"
  add_foreign_key "activity_logs", "users"
  add_foreign_key "contacts", "organizations"
  add_foreign_key "gdpr_admin_data_retention_policies", "organizations", column: "tenant_id"
  add_foreign_key "gdpr_admin_requests", "admin_users", column: "requester_id"
  add_foreign_key "gdpr_admin_requests", "organizations", column: "tenant_id"
  add_foreign_key "users", "organizations"
end
