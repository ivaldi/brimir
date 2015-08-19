# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150807135450) do

  create_table "attachments", force: :cascade do |t|
    t.integer  "attachable_id"
    t.string   "attachable_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_file_name",    limit: 255
    t.string   "file_content_type", limit: 255
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
  end

  add_index "attachments", ["attachable_id"], name: "index_attachments_on_attachable_id"

  create_table "email_addresses", force: :cascade do |t|
    t.string   "email"
    t.boolean  "default",            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "verification_token"
    t.string   "name"
  end

  create_table "identities", force: :cascade do |t|
    t.integer "user_id"
    t.string  "uid"
    t.string  "provider"
  end

  add_index "identities", ["user_id"], name: "index_identities_on_user_id"

  create_table "labelings", force: :cascade do |t|
    t.integer  "label_id"
    t.integer  "labelable_id"
    t.string   "labelable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "labelings", ["label_id", "labelable_id", "labelable_type"], name: "unique_labeling_label", unique: true
  add_index "labelings", ["label_id"], name: "index_labelings_on_label_id"
  add_index "labelings", ["labelable_id", "labelable_type"], name: "index_labelings_on_labelable_id_and_labelable_type"

  create_table "labels", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "color",      limit: 255
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "notifiable_id"
    t.string   "notifiable_type", limit: 255
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notifications", ["notifiable_id", "notifiable_type", "user_id"], name: "unique_notification", unique: true
  add_index "notifications", ["notifiable_id", "notifiable_type"], name: "index_notifications_on_notifiable_id_and_notifiable_type"
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id"

  create_table "replies", force: :cascade do |t|
    t.text     "content",      limit: 1073741823
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ticket_id"
    t.integer  "user_id"
    t.string   "message_id",   limit: 255
    t.string   "content_type", limit: 255,        default: "html"
  end

  add_index "replies", ["message_id"], name: "index_replies_on_message_id"
  add_index "replies", ["ticket_id"], name: "index_replies_on_ticket_id"
  add_index "replies", ["user_id"], name: "index_replies_on_user_id"

  create_table "rules", force: :cascade do |t|
    t.string   "filter_field",     limit: 255
    t.integer  "filter_operation",             default: 0, null: false
    t.string   "filter_value",     limit: 255
    t.integer  "action_operation",             default: 0, null: false
    t.string   "action_value",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "status_changes", force: :cascade do |t|
    t.integer  "ticket_id"
    t.integer  "status",     default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "status_changes", ["ticket_id"], name: "index_status_changes_on_ticket_id"

  create_table "tenants", force: :cascade do |t|
    t.string   "domain"
    t.string   "from"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tickets", force: :cascade do |t|
    t.string   "subject",             limit: 255
    t.text     "content",             limit: 1073741823
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assignee_id"
    t.string   "message_id",          limit: 255
    t.integer  "user_id"
    t.string   "content_type",        limit: 255,        default: "html"
    t.integer  "status",                                 default: 0,      null: false
    t.integer  "priority",                               default: 0,      null: false
    t.integer  "to_email_address_id"
    t.integer  "locked_by_id"
    t.datetime "locked_at"
  end

  add_index "tickets", ["assignee_id"], name: "index_tickets_on_assignee_id"
  add_index "tickets", ["locked_by_id"], name: "index_tickets_on_locked_by_id"
  add_index "tickets", ["message_id"], name: "index_tickets_on_message_id"
  add_index "tickets", ["priority"], name: "index_tickets_on_priority"
  add_index "tickets", ["status"], name: "index_tickets_on_status"
  add_index "tickets", ["to_email_address_id"], name: "index_tickets_on_to_email_address_id"
  add_index "tickets", ["user_id"], name: "index_tickets_on_user_id"

  create_table "users", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  limit: 255, default: "",          null: false
    t.string   "encrypted_password",     limit: 255, default: "",          null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.boolean  "agent"
    t.text     "signature"
    t.boolean  "notify",                             default: true
    t.string   "authentication_token",   limit: 255
    t.string   "time_zone",              limit: 255, default: "Amsterdam"
    t.integer  "per_page",                           default: 30,          null: false
    t.string   "locale",                 limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
