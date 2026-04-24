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

ActiveRecord::Schema[7.0].define(version: 2025_01_09_231432) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "ai_documents_pools", force: :cascade do |t|
    t.string "job_id"
    t.string "status"
    t.bigint "deal_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "response"
    t.index ["deal_id"], name: "index_ai_documents_pools_on_deal_id"
    t.index ["job_id"], name: "index_ai_documents_pools_on_job_id"
    t.index ["status"], name: "index_ai_documents_pools_on_status"
  end

  create_table "broker_lenders", force: :cascade do |t|
    t.integer "lender_id"
    t.integer "broker_id"
    t.integer "status", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["broker_id"], name: "index_broker_lenders_on_broker_id"
    t.index ["lender_id"], name: "index_broker_lenders_on_lender_id"
  end

  create_table "deal_lenders", force: :cascade do |t|
    t.integer "lender_id", null: false
    t.bigint "deal_id", null: false
    t.decimal "commited_capital", default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "envelope_id"
    t.datetime "signed_at", precision: nil
    t.datetime "signature_sent_at"
    t.index ["deal_id"], name: "index_deal_lenders_on_deal_id"
    t.index ["lender_id", "deal_id"], name: "index_deal_lenders_on_lender_id_and_deal_id", unique: true
  end

  create_table "deals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "details", default: {}
    t.integer "user_id", null: false
    t.integer "state", default: 0
    t.text "rejected_description"
    t.boolean "bookmarked", default: false
    t.integer "rejected_actor_id"
    t.datetime "approved_signatures_at", precision: nil
    t.string "url_code"
    t.text "property_details"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_deals_on_deleted_at"
    t.index ["state"], name: "index_deals_on_state"
    t.index ["user_id"], name: "index_deals_on_user_id"
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "maintenance_tasks_runs", force: :cascade do |t|
    t.string "task_name", null: false
    t.datetime "started_at", precision: nil
    t.datetime "ended_at", precision: nil
    t.float "time_running", default: 0.0, null: false
    t.bigint "tick_count", default: 0, null: false
    t.bigint "tick_total"
    t.string "job_id"
    t.string "cursor"
    t.string "status", default: "enqueued", null: false
    t.string "error_class"
    t.string "error_message"
    t.text "backtrace"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "arguments"
    t.integer "lock_version", default: 0, null: false
    t.text "metadata"
    t.index ["task_name", "status", "created_at"], name: "index_maintenance_tasks_runs", order: { created_at: :desc }
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id"
    t.integer "notificable_id"
    t.text "content"
    t.string "notificable_type"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", limit: 2, default: 0, null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.integer "invited_by_id"
    t.string "invited_by_type"
    t.jsonb "profile", default: {}
    t.string "locale", default: "en"
    t.datetime "approved_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "ai_documents_pools", "deals"
  add_foreign_key "deal_lenders", "deals"
end
