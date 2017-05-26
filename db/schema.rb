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

ActiveRecord::Schema.define(version: 20170526072913) do

  create_table "service_providers", force: :cascade do |t|
    t.string "app_id", null: false
    t.integer "auth_level"
    t.string "credential", null: false
    t.string "secret_key", null: false
    t.integer "user_id", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "callback_url", null: false
    t.string "salt"
    t.index ["app_id"], name: "index_service_providers_on_app_id", unique: true
    t.index ["user_id"], name: "index_service_providers_on_user_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.integer "service_provider_id", null: false
    t.integer "user_id", null: false
    t.string "request_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_provider_id"], name: "index_tickets_on_service_provider_id"
    t.index ["user_id"], name: "index_tickets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "user_name"
    t.string "emp_id", null: false
    t.string "mobile_phone", null: false
    t.string "email", null: false
    t.string "credential"
    t.integer "role", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remember_digest"
    t.index ["user_name"], name: "index_users_on_user_name", unique: true
  end

end
