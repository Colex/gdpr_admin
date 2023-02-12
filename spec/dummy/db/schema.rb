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

ActiveRecord::Schema[7.0].define(version: 2023_02_12_185817) do
  create_table "gdpr_admin_tasks", force: :cascade do |t|
    t.integer "tenant_id", null: false
    t.integer "requester_id", null: false
    t.string "request"
    t.string "status"
    t.datetime "data_older_than"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["requester_id"], name: "index_gdpr_admin_tasks_on_requester_id"
    t.index ["tenant_id"], name: "index_gdpr_admin_tasks_on_tenant_id"
  end

  add_foreign_key "gdpr_admin_tasks", "requesters"
  add_foreign_key "gdpr_admin_tasks", "tenants"
end
