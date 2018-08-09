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

ActiveRecord::Schema.define(version: 2018_08_09_084644) do

  create_table "account_events", force: :cascade do |t|
    t.integer "event_type"
    t.string "event_token"
    t.boolean "finished"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_account_events_on_user_id"
  end

  create_table "employee_refs", force: :cascade do |t|
    t.string "emp_id"
    t.string "full_name"
    t.string "kana"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_employee_refs_on_email", unique: true
  end

  create_table "feedbacks", force: :cascade do |t|
    t.string "email"
    t.string "info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

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
    t.string "revoke_url"
    t.string "app_name"
    t.string "home_page"
    t.boolean "test_use_only", default: false
    t.index ["app_id"], name: "index_service_providers_on_app_id", unique: true
    t.index ["user_id"], name: "index_service_providers_on_user_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.integer "service_provider_id", null: false
    t.integer "user_id", null: false
    t.string "request_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "used"
    t.string "email"
    t.index ["service_provider_id"], name: "index_tickets_on_service_provider_id"
    t.index ["user_id"], name: "index_tickets_on_user_id"
  end

  create_table "user_securities", force: :cascade do |t|
    t.integer "user_id"
    t.string "otp_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_securities_on_user_id"
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
    t.string "display_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["user_name"], name: "index_users_on_user_name", unique: true
  end

end
