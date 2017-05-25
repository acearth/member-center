# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170525002549) do

  create_table "service_providers", force: :cascade do |t|
    t.string "app_id"
    t.integer "auth_level"
    t.string "credential"
    t.string "secret_key"
    t.integer "user_id"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_service_providers_on_user_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.integer "service_provider_id"
    t.integer "user_id"
    t.string "request_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_provider_id"], name: "index_tickets_on_service_provider_id"
    t.index ["user_id"], name: "index_tickets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "user_name"
    t.string "emp_id"
    t.string "mobile_phone"
    t.string "email"
    t.string "credential"
    t.integer "role"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remember_digest"
    t.index ["user_name"], name: "index_users_on_user_name"
  end

end
