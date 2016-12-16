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

ActiveRecord::Schema.define(version: 20161214155109) do

  create_table "attachments", force: :cascade do |t|
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.string   "content_id"
    t.index ["attachable_id"], name: "index_attachments_on_attachable_id"
  end

  create_table "email_addresses", force: :cascade do |t|
    t.string   "email"
    t.boolean  "default",            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "verification_token"
    t.string   "name"
  end

  create_table "email_templates", force: :cascade do |t|
    t.string   "name"
    t.text     "message"
    t.integer  "kind",                      null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.boolean  "draft",      default: true, null: false
  end

  create_table "identities", force: :cascade do |t|
    t.integer "user_id"
    t.string  "uid"
    t.string  "provider"
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "labelings", force: :cascade do |t|
    t.integer  "label_id"
    t.string   "labelable_type"
    t.integer  "labelable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["label_id", "labelable_id", "labelable_type"], name: "unique_labeling_label", unique: true
    t.index ["label_id"], name: "index_labelings_on_label_id"
    t.index ["labelable_type", "labelable_id"], name: "index_labelings_on_labelable_type_and_labelable_id"
  end

  create_table "labels", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "color"
  end

  create_table "notifications", force: :cascade do |t|
    t.string   "notifiable_type"
    t.integer  "notifiable_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["notifiable_id", "notifiable_type", "user_id"], name: "unique_notification", unique: true
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "replies", force: :cascade do |t|
    t.text     "content",                  limit: 1073741823
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ticket_id"
    t.integer  "user_id"
    t.string   "message_id"
    t.string   "content_type",                                default: "html"
    t.boolean  "draft",                                       default: false,  null: false
    t.string   "raw_message_file_name"
    t.string   "raw_message_content_type"
    t.integer  "raw_message_file_size"
    t.datetime "raw_message_updated_at"
    t.boolean  "internal",                                    default: false,  null: false
    t.string   "type"
    t.index ["message_id"], name: "index_replies_on_message_id"
    t.index ["ticket_id"], name: "index_replies_on_ticket_id"
    t.index ["user_id"], name: "index_replies_on_user_id"
  end

  create_table "rules", force: :cascade do |t|
    t.string   "filter_field"
    t.integer  "filter_operation", default: 0, null: false
    t.string   "filter_value"
    t.integer  "action_operation", default: 0, null: false
    t.string   "action_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schedules", force: :cascade do |t|
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.datetime "start"
    t.datetime "end"
    t.boolean  "monday",     default: true,  null: false
    t.boolean  "tuesday",    default: true,  null: false
    t.boolean  "wednesday",  default: true,  null: false
    t.boolean  "thursday",   default: true,  null: false
    t.boolean  "friday",     default: true,  null: false
    t.boolean  "saturday",   default: false, null: false
    t.boolean  "sunday",     default: false, null: false
  end

  create_table "status_changes", force: :cascade do |t|
    t.integer  "ticket_id"
    t.integer  "status",     default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ticket_id"], name: "index_status_changes_on_ticket_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.string   "domain"
    t.string   "from"
    t.datetime "created_at",                                                            null: false
    t.datetime "updated_at",                                                            null: false
    t.string   "default_time_zone",                               default: "Amsterdam"
    t.boolean  "ignore_user_agent_locale",                        default: false,       null: false
    t.string   "default_locale",                                  default: "en"
    t.boolean  "share_drafts",                                    default: false
    t.boolean  "first_reply_ignores_notified_agents",             default: false,       null: false
    t.boolean  "notify_client_when_ticket_is_assigned_or_closed", default: false,       null: false
    t.boolean  "notify_user_when_account_is_created",             default: false
    t.boolean  "notify_client_when_ticket_is_created",            default: false
    t.integer  "email_template_id"
    t.boolean  "ticket_creation_is_open_to_the_world",            default: true
    t.string   "stylesheet_url"
    t.index ["domain"], name: "index_tenants_on_domain", unique: true
    t.index ["email_template_id"], name: "index_tenants_on_email_template_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.string   "subject"
    t.text     "content",                  limit: 1073741823
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assignee_id"
    t.string   "message_id"
    t.integer  "user_id"
    t.string   "content_type",                                default: "html"
    t.integer  "status",                                      default: 0,      null: false
    t.integer  "priority",                                    default: 0,      null: false
    t.integer  "to_email_address_id"
    t.integer  "locked_by_id"
    t.datetime "locked_at"
    t.string   "raw_message_file_name"
    t.string   "raw_message_content_type"
    t.integer  "raw_message_file_size"
    t.datetime "raw_message_updated_at"
    t.string   "orig_to"
    t.string   "orig_cc"
    t.index ["assignee_id"], name: "index_tickets_on_assignee_id"
    t.index ["locked_by_id"], name: "index_tickets_on_locked_by_id"
    t.index ["message_id"], name: "index_tickets_on_message_id"
    t.index ["priority"], name: "index_tickets_on_priority"
    t.index ["status"], name: "index_tickets_on_status"
    t.index ["to_email_address_id"], name: "index_tickets_on_to_email_address_id"
    t.index ["user_id"], name: "index_tickets_on_user_id"
  end

  create_table "tickets_users", id: false, force: :cascade do |t|
    t.integer "ticket_id", null: false
    t.integer "user_id",   null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "agent",                  default: false, null: false
    t.text     "signature"
    t.boolean  "notify",                 default: true
    t.string   "authentication_token"
    t.string   "time_zone"
    t.integer  "per_page",               default: 30,    null: false
    t.string   "locale"
    t.boolean  "prefer_plain_text",      default: false, null: false
    t.boolean  "include_quote_in_reply", default: true,  null: false
    t.string   "name"
    t.integer  "schedule_id"
    t.boolean  "schedule_enabled",       default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["schedule_id"], name: "index_users_on_schedule_id"
  end

end
